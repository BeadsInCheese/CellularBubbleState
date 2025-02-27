extends Sprite2D

class_name Board
@export
var bubble = preload("Bubble.tscn")
@export
var gui: GUI
@export
var xsize: int = 12
@export
var ysize: int = 12


var gridList: Array[Bubble] = []
var latestTileIndexes: Array[int] = []
static var boardHistory : Array[String] = []
var currentBoardStatePointer = 0

enum Players{PLAYER1=1,PLAYER2=3,AUTOMATA=0}
var turnOrder=[]
var currentTurn=0
var player1Score = 0
var player2Score = 0

var p1cursor=preload("res://CursorImages/Player1.png")
var p2cursor=preload("res://CursorImages/Player2.png")

var lastMove=[-1,-1]

var p1AgentInstance
var p2AgentInstance
var player1Agent=load("res://AI/LDAgent.gd")
var player2Agent=load("res://AI/PlayerAgent.gd")
var agentlist=[load("res://AI/PlayerAgent.gd"),load("res://AI/RandomAIAgent.gd"),load("res://AI/MinimaxAgent.gd"),load("res://AI/LDAgent.gd")]
var automataAgent: AutomataAgent = load("res://AI/AutomataAgent.gd").new()

var victor=-1
func isEnd()->bool:
	for i in gridList:
		if(i.tileType==0):
			return false
	return true
	
func updateScore():
	player1Score=0
	player2Score=0
	for i in gridList:
		if(i.tileType == 1 or i.tileType == 2):
			player1Score += 1
		if(i.tileType == 3 or i.tileType == 4):
			player2Score += 1

var announced=false
func changeTurn()->void:
	await turnOrder[currentTurn].makeMove(self)
	currentTurn = (currentTurn+1) % 6
	
	boardHistory.resize(currentBoardStatePointer+1)
	boardHistory.append(DataUtility.get_board_string(gridList,currentTurn))
	currentBoardStatePointer += 1
	
	if(not(isEnd())):
		changeTurn()

	updateScore()
	gui.updateSidebar(currentTurn,player1Score,player2Score)
	updateCursor()
	if(!announced and isEnd()):
		announced=true
		var x = load("res://VictorAnnouncement.tscn").instantiate()
		if player1Score==player2Score:
			victor=0.5
		elif player1Score>player2Score:
			victor=0
		else:
			victor=1
		for i in turnOrder:
			i.destructor(self)
		x.get_node("Text").text="[center]DRAW[/center]" if player1Score==player2Score  else "[center]Player 1 Wins[/center]" if player1Score>player2Score else "[center]Player 2 Wins[/center]"  
		add_child(x)
		
	

func updateCursor():
	var new_cursor_image =p1cursor if(turnOrder[currentTurn].playerType==Players.PLAYER1) else p2cursor
	Input.set_custom_mouse_cursor(new_cursor_image, Input.CURSOR_ARROW, Vector2(15,15))

# Called when the node enters the scene tree for the first time.
static var mp=true
var temp=load("res://AI/LDAgent.gd")
var temp2=load("res://AI/PlayerAgent.gd")
func _ready() -> void:
	
	for i in range(xsize):
		for j in range(ysize):
			var x:Bubble=bubble.instantiate()
			x.tileType=0
			x.tileIndex=j+i*xsize
			
			add_child(x)
			gridList.append(x)
			
	boardHistory.append(DataUtility.get_board_string(gridList,currentTurn))
	if(mp):

		p1AgentInstance= temp.new()
		p1AgentInstance.playerType=Players.PLAYER1
		p2AgentInstance=temp2.new()
		p2AgentInstance.playerType=Players.PLAYER2
	else:
		p1AgentInstance= agentlist[Settings.P1Index].new()
		p1AgentInstance.playerType=Players.PLAYER1
		p2AgentInstance=agentlist[Settings.P2Index].new()
		p2AgentInstance.playerType=Players.PLAYER2
	
	await p1AgentInstance.init(self)
	await p2AgentInstance.init(self)
	
	turnOrder.append(p1AgentInstance)
	turnOrder.append(p2AgentInstance)
	turnOrder.append(automataAgent)
	turnOrder.append(p2AgentInstance)
	turnOrder.append(p1AgentInstance)
	turnOrder.append(automataAgent)
	
	for i in turnOrder:
		print(i.get_custom_class_name())
		
	moveToplace()
	updateCursor()
	changeTurn()


func moveToplace()->void:
	for i in range(len(gridList)):
		var xpos:int=i%xsize
		var ypos:int=i/ysize
		gridList[i].position=Vector2(xpos,ypos)*52+Vector2(38,38)
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func getBoardCopy() -> Array:
	var board = []
	board.resize(len(gridList))
		
	for i in range(len(gridList)):
		board[i] = gridList[i].tileType
	
	return board

func getGridTileType(xpos: int, ypos: int, board: Array):
	if xpos < 0 or ypos < 0 or xpos >= xsize or ypos >= ysize:
		return null

	return board[xpos + ypos * ysize]

func decode_board():
	var s = boardHistory[currentBoardStatePointer]
	currentTurn = int(s[len(s) - 1])
	s = DataUtility.decode(s.substr(0,len(s)-1))
	for i in range(0,len(s)):
		gridList[i].setTileType(int(s[i]))
	print("board history ",boardHistory)

func _on_tree_exiting() -> void:
	Input.set_custom_mouse_cursor(null)


func _skip_button_pressed() -> void:
	turnOrder[currentTurn].skip=!turnOrder[currentTurn].skip

func _save_button_pressed() -> void:
	DataUtility.save_to_file(boardHistory, Time.get_datetime_string_from_system())
	
func _load_button_pressed() -> void:
	var x : Node2D = load("res://LoadGame.tscn").instantiate()
	add_child(x)


func _mute_button_pressed() -> void:
	if Settings.masterVolume == 0:
		Settings.setMaster(80)
	else:
		Settings.setMaster(0)

func _exit_button_pressed() -> void:
	boardHistory.clear()
	SceneNavigation._on_MainMenuPressed()

func _input(event):
	if event is InputEventKey and event.pressed:
		if (event.as_text() == "Left" && (turnOrder[(len(boardHistory)-1)%6].get_is_player() || isEnd())):
			currentBoardStatePointer -= 1
			currentBoardStatePointer = clampi(currentBoardStatePointer,0,len(boardHistory)-1)
			#print("pointer=",currentBoardStatePointer," turn=",currentTurn)
			decode_board()
			update_meta()
		elif(event.as_text() == "Right" && (turnOrder[(len(boardHistory)-1)%6].get_is_player() || isEnd())):
			currentBoardStatePointer += 1
			currentBoardStatePointer = clampi(currentBoardStatePointer,0,len(boardHistory)-1)
			#print("pointer=",currentBoardStatePointer," turn=",currentTurn)
			decode_board()
			update_meta()

func update_meta():
	updateScore()
	gui.updateSidebar(currentTurn,player1Score,player2Score)
	updateCursor()


func _on_reset_button_pressed() -> void:
	pass
	

extends Sprite2D

class_name Board
@export
var bubble = preload("Bubble.tscn")
var tutorialPanel = preload("res://Tutorial.tscn")
@export
var gui: GUI
@export
var xsize: int = 12
@export
var ysize: int = 12

var currentAgent
var gridList: Array[Bubble] = []
var latestTileIndexes: Array[int] = []
var latestAutomataIndexes: Array[int] = []

static var boardHistory : Array[String] = []
static var boardExists=false
var currentBoardStatePointer = 0
var loading = false
var hasEnded=false
static var tutorial = false
static var adventure=false
enum Players{PLAYER1=1,PLAYER2=3,AUTOMATA=0}
var turnOrder=[]
var currentTurn=0
var absoluteTurn = 0
var player1Score = 0
var player2Score = 0

var p1cursor=preload("res://CursorImages/Player1.png")
var p2cursor=preload("res://CursorImages/Player2.png")

var lastMove=[-1,-1]

var p1AgentInstance
var p2AgentInstance

static var mp = true

var playerAgent=load("res://AI/PlayerAgent.gd")
var multiplayerAgent=load("res://AI/MultiplayerAgent.gd")
var tutorialAgent=load("res://TutorialAgent.gd")
var agentlist=[playerAgent,load("res://AI/RandomAIAgent.gd"),load("res://AI/MinimaxGolgathAgent.gd"),load("res://AI/LDAgent.gd"),load("res://AI/BasicHeuristicEval.gd"),load("res://AI/MinimaxStrategolAgent.gd"),load("res://AI/RandomFollowerAgent.gd")]
var automataAgent: AutomataAgent = load("res://AI/AutomataAgent.gd").new()

signal turnChangedSignal(absoluteTurn: int)

var victor=-1

## Check if the board exists and is in the tree
func exists() -> bool:
	return boardExists and is_inside_tree() and get_tree() != null

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

func asArray():
	var arr=[]
	for i in gridList:
		arr.append(i.tileType)
	return arr

func getVictor():
	var v
	if player1Score==player2Score:
		v=0.5
	elif player1Score>player2Score:
		v=0
	else:
		v=1
	return v

var dataAquisition=false
var dataCounter=0

func changeTurn()->void:
	currentAgent = turnOrder[currentTurn]
	await turnOrder[currentTurn].makeMove(self)
	
	#print("type",currentAgent.playerType)
	if(!loading):
		currentTurn = (currentTurn+1) % 6
		absoluteTurn += 1
		boardHistory.resize(currentBoardStatePointer+1)
		boardHistory.append(DataUtility.get_board_string(gridList,currentTurn))
		currentBoardStatePointer += 1
	else:
		loading = false
	
	updateScore()
	#print(player1Score,"   ",player2Score)
	if(not isEnd() and not hasEnded):
		changeTurn()
		turnChangedSignal.emit(absoluteTurn)

	if dataAquisition and isEnd():
		#print(boardHistory)
		#_trainSave_button_pressed()
		turnOrder[0].onTrainEnd(boardHistory,getVictor())
		turnOrder[1].onTrainEnd(boardHistory,getVictor())
		for i in gridList:
			i.setTileType(0)
		currentBoardStatePointer=0
		boardHistory=[]
		#trainer.delete_folder_contents("Train/TrainingData")
		dataCounter+=1
			
			
		changeTurn()
		pass
	gui.updateSidebar(currentTurn,player1Score,player2Score,turnOrder[currentTurn].get_is_player())
	updateCursor()
	if(!hasEnded and isEnd()):
		hasEnded=true
		var x = load("res://VictorAnnouncement.tscn").instantiate()
		if player1Score==player2Score:
			victor=0.5
		elif player1Score>player2Score:
			victor=0
		else:
			victor=1
		for i in turnOrder:
			i.destructor(self)
		x.get_node("ColorRect/VBoxContainer/Text").text="[center]DRAW[/center]" if player1Score==player2Score  else "[center]Player 1 Wins[/center]" if player1Score>player2Score else "[center]Player 2 Wins[/center]"  
		if(adventure and player1Score>player2Score):
			Map.fightsWon=max(Map.fightsWon,Settings.P2Index)
		add_child(x)
		
	

func updateCursor():
	var new_cursor_image =p1cursor if(turnOrder[currentTurn].playerType==Players.PLAYER1) else p2cursor
	Input.set_custom_mouse_cursor(new_cursor_image, Input.CURSOR_ARROW, Vector2(15,15))

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	boardExists = true
	for i in range(xsize):
		for j in range(ysize):
			var x:Bubble=bubble.instantiate()
			x.tileType=0
			x.tileIndex=j+i*xsize
			
			add_child(x)
			gridList.append(x)
			
	boardHistory.append(DataUtility.get_board_string(gridList,currentTurn))
	
	if mp:
		p1AgentInstance = playerAgent.new()
		p2AgentInstance = multiplayerAgent.new()
	if tutorial:
		p1AgentInstance = playerAgent.new()
		p2AgentInstance = tutorialAgent.new()
	else:
		p1AgentInstance = agentlist[Settings.P1Index].new()
		p2AgentInstance = agentlist[Settings.P2Index].new()

	p1AgentInstance.playerType=Players.PLAYER1
	p2AgentInstance.playerType=Players.PLAYER2
	
	await p1AgentInstance.init(self)
	await p2AgentInstance.init(self)
	await automataAgent.init(self)
	
	turnOrder.append(p1AgentInstance)
	turnOrder.append(p2AgentInstance)
	turnOrder.append(automataAgent)
	turnOrder.append(p2AgentInstance)
	turnOrder.append(p1AgentInstance)
	turnOrder.append(automataAgent)
	
	for i in turnOrder:
		print(i.get_custom_class_name())
	
	if tutorial:
		var x = tutorialPanel.instantiate()
		add_child(x)
	
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
static func getGridTileTypeStatic(xsize:int,ysize:int,xpos: int, ypos: int, board: Array):
	if xpos < 0 or ypos < 0 or xpos >= xsize or ypos >= ysize:
		return null

	return board[xpos + ypos * ysize]


func decodeBoard(pointer):
	var s = boardHistory[pointer]
	currentTurn = int(s[len(s) - 1])
	s = DataUtility.decode(s.substr(0,len(s)-1))
	for i in range(0,len(s)):
		if gridList[i].tileType != int(s[i]):
			gridList[i].setTileType(int(s[i]))


func _on_tree_exiting() -> void:
	Input.set_custom_mouse_cursor(null)


func _skip_button_pressed() -> void:
	turnOrder[currentTurn].skip=!turnOrder[currentTurn].skip

func _save_button_pressed() -> void:
	DataUtility.save_to_file(boardHistory, "save-"+Time.get_datetime_string_from_system(),"res://Saves")
func _trainSave_button_pressed() -> void:
	DataUtility.save_to_file(boardHistory, str(getVictor())+Time.get_datetime_string_from_system(),"res://Train/TrainingData")
	
func _load_button_pressed() -> void:
	var x : Node2D = load("res://LoadGame.tscn").instantiate()
	add_child(x)


func _mute_button_pressed() -> void:
	if Settings.masterVolume == 0:
		Settings.setMaster(80)
	else:
		Settings.setMaster(0)

func _exit_button_pressed() -> void:
	SceneNavigation._on_MainMenuPressed()
	hasEnded = true
	
func _exit_tree() -> void:
	boardHistory.clear()
	boardExists = false
	hasEnded = true
	
func _input(event):
	if event is InputEventKey and event.pressed:
		if (event.as_text() == "Left" && (turnOrder[(len(boardHistory)-1)%6].get_is_player() || hasEnded)):
			currentBoardStatePointer -= 1
			currentBoardStatePointer = clampi(currentBoardStatePointer,0,len(boardHistory)-1)
			#print("pointer=",currentBoardStatePointer," turn=",currentTurn)
			decodeBoard(currentBoardStatePointer)
			updateMeta()
			turnChangedSignal.emit(absoluteTurn)

		elif(event.as_text() == "Right" && (turnOrder[(len(boardHistory)-1)%6].get_is_player() || hasEnded)):
			currentBoardStatePointer += 1
			currentBoardStatePointer = clampi(currentBoardStatePointer,0,len(boardHistory)-1)
			#print("pointer=",currentBoardStatePointer," turn=",currentTurn)
			decodeBoard(currentBoardStatePointer)
			updateMeta()
			turnChangedSignal.emit(absoluteTurn)

func updateMeta():
	updateScore()
	gui.updateSidebar(currentTurn,player1Score,player2Score,turnOrder[currentTurn].get_is_player())
	updateCursor()


func _on_reset_button_pressed() -> void:
	pass
	

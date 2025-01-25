extends Sprite2D

class_name Board
@export
var bubble = preload("Bubble.tscn")
@export
var gui :GUI
@export
var xsize : int = 17
@export
var ysize : int = 17

var gridList=[]
enum Players{PLAYER1=1,PLAYER2=3,AUTOMATA=0}
var turnOrder=[Players.PLAYER1,Players.PLAYER2,Players.AUTOMATA,Players.PLAYER2,Players.PLAYER1,Players.AUTOMATA]
var currentTurn=0
var player1Score = 0
var player2Score = 0
func updateScore():
	player1Score=0
	player2Score=0
	for i in gridList:
		if(i.tileType==1 or i.tileType== 2):
			player1Score+=1
		if(i.tileType==3 or i.tileType == 4):
			player2Score+=1
			
func changeTurn()->void:
	currentTurn=(currentTurn+1)%6
	
	if(turnOrder[currentTurn]==Players.AUTOMATA):
		automata_step()
		changeTurn()
	updateScore()
	gui.updateSidebar(turnOrder[currentTurn],player1Score,player2Score)
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(xsize):
		for j in range(ysize):
			var x:Bubble=bubble.instantiate()
			x.tileType=0
			
			add_child(x)
			gridList.append(x)
	moveToplace()
	
func moveToplace()->void:
	for i in range(len(gridList)):
		var xpos:int=i%xsize
		var ypos:int=i/ysize
		gridList[i].position=Vector2(xpos,ypos)*38+Vector2(20,20)
func automata_step() -> void:
	for i in range(len(gridList)):
		var xpos:int=i%xsize
		var ypos:int=i/ysize
		
		pass
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_button_down() -> void:
	player1Score = player1Score+1
	changeTurn()
	automata_step()

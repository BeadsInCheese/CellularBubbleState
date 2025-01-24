extends Sprite2D


@export
var bubble = preload("Bubble.tscn")
@export
var xsize : int = 20
@export
var ysize : int = 20

var gridList=[]
enum Players{PLAYER1,PLAYER2,AUTOMATA}
var turnOrder=[Players.PLAYER1,Players.PLAYER2,Players.AUTOMATA,Players.PLAYER2,Players.PLAYER1,Players.AUTOMATA]
var currentTurn=0



func changeTurn()->void:
	currentTurn=(currentTurn+1)%6
	if(turnOrder[currentTurn]==Players.AUTOMATA):
		pass
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
		gridList[i].position=Vector2(xpos,ypos)*24+Vector2(20,20)
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
	automata_step()

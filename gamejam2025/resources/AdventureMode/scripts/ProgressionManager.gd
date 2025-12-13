extends CanvasLayer


# Called when the node enters the scene tree for the first time.
var achievements={}
@export 
var data:Array[enemyResource]


func adventureDialogueDecode(i:int):
	await $DialogueBox.playDialogue(data[i].dialogue)
	Settings.P1Index=0
	Settings.P2Index=1
	SceneNavigation.goToScene("res://MainGame.tscn")
func _ready() -> void:
	Board.tutorial=false
	Board.adventure=true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func Larry_button_pressed(opponent) -> void:
	adventureDialogueDecode(opponent)
	

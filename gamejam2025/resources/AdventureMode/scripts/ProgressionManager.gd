extends CanvasLayer

class_name Map
# Called when the node enters the scene tree for the first time.
var achievements={}
@export 
var data:Array[enemyResource]

static var fightsWon=0
func adventureDialogueDecode(i:int):
	await $DialogueBox.playDialogue(data[i].dialogue)

func _ready() -> void:
	Board.tutorial=false
	Board.adventure=true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func Larry_button_pressed(opponent) -> void:
	await adventureDialogueDecode(opponent)
	Settings.P1Index=0
	Settings.P2Index=1
	SceneNavigation._onLocalMPSelected()

extends "res://AI/AgentBase.gd"

class_name TutorialAgent

var gameBoard
var agentStage = 0

#[66,43,67,64,64,43,90,78,89,90,51]
var t = [43,67,43,56,89,103]

func makeMove(observation:Board):
	makingMove=true
	
	print("agentStage=",agentStage)
	gameBoard = observation
	await observation.get_tree().create_timer(0.5).timeout
	if(len(t)>agentStage):
		gameBoard.gridList[t[agentStage]].setTileType(3, false)
		agentStage += 1

		moveMade.emit(observation)
	
	
func _ready() -> void:
	pass
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func get_custom_class_name():
	return "TutorialAgent"
func get_is_player() -> bool:
	return false

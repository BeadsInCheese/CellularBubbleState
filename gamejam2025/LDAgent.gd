extends Node
#extends "res://AI/AgentBase.gd"
class_name LDAgent

func makeMove(observation:Board):
	var agent : Agent = Agent.new()
	#await observation.get_tree().create_timer(0.5).timeout
	#var game_board = agent.proceduralMove(observation)
	#moveMade.emit(game_board)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_custom_class_name():
	return "LDAgent"

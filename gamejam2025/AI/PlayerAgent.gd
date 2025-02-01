extends "res://AI/AgentBase.gd"

class_name PlayerAgent
# Called when the node enters the scene tree for the first time.

func makeMove(observation:Board):
	pass

func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func get_custom_class_name():
	return "PlayerAgent"
func get_is_player() -> bool:
	return true

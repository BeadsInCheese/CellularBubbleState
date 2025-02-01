
class_name AgentBase
var isPlayer=false
var playerType=1
func makeMove(observation:Board):
	pass
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func get_custom_class_name():
	return "AgentBase"
func get_is_player() -> bool:
	return false

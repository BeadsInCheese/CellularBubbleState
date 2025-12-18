extends AgentBase


class_name BTAgent
var root:BTNode=preload("res://AI/BTTree/root.tres")
func makeMove(observation:Board):
	await root.evaluate(observation,playerType)
	if(!Board.boardExists):
		return
	moveMade.emit(observation)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'd+elta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func get_custom_class_name():
	return "BTAgent"

extends Node
class_name Agent

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func proceduralMove(currentTurn,color,board) -> Bubble:
	print(str(board[0]))
	return board[16]

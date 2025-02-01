extends Node
class_name Agent

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func proceduralMove(currentTurn,color,board) -> Bubble:
	var m = 0
	var i = 1
	var result = 0
	
	while m < 500:
		i = (int)(1000*(1000*sin(i)-(int)(1000*sin(i)))) % len(board)
		m = m+1
		if board[i].tileType == 0:
			result = i
			break;
	return board[result]

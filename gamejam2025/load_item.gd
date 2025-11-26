extends Button
class_name LoadItem

var n = 0
var list : Array[String]

func _button_pressed():
	
	var board : Board = find_parent("Board")
	
	print("currentAgent",board.currentAgent.playerType)
	
	board.boardHistory = DataUtility.load_from_file(n)
	board.currentBoardStatePointer = len(board.boardHistory)-1
	board.decode_board(board.currentBoardStatePointer)

	board.loading = true
	board.currentAgent.makingMove = false
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

extends Button
class_name LoadItem

var n = 0
var list : Array[String]

func _button_pressed():
	
	var board = find_parent("Board")#get_parent().get_parent().get_parent().get_parent()
	board.boardHistory = DataUtility.load_from_file(n)
	board.decode_board()
	get_tree().root.get_node("root/Sidebar/statusLabel").set_text("save loaded!")
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

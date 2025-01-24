extends Node2D
class_name Bubble
var tileType=1
var board:Board
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	board=get_tree().get_root().get_node("root/Board")
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$RichTextLabel.text="[center]"+str(tileType)+"[/center]"


func _on_button_button_down() -> void:
	if(board.turnOrder[board.currentTurn]!=board.Players.AUTOMATA):
		print(tileType)
		tileType=board.turnOrder[board.currentTurn]
		board.changeTurn()
		$Button.visible=false
	
	pass # Replace with function body.

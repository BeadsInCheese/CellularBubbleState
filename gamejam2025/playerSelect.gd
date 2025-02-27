extends Node2D

func setPlayer1(index):
	print("setPlayer1 to "+str(index))
	Settings.P1Index=index

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Board.mp=false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_button_button_down() -> void:
	SceneNavigation._onLocalMPSelected()


func _on_back_button_button_down() -> void:
	SceneNavigation._on_MainMenuPressed()


func _on_option_button_2_item_selected(index: int) -> void:
	print("setPlayer2 to "+str(index))
	Settings.P2Index=index


func _on_back_button_pressed() -> void:
	SceneNavigation._on_MainMenuPressed()

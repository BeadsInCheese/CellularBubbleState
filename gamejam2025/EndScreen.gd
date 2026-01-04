extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if(Board.adventure):
		text="Back to map"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_down() -> void:
	get_tree().root.get_node("root/Board").boardHistory.clear()
	if(Board.adventure):
		SceneNavigation.go_to_map()
	else:
		SceneNavigation.go_to_main_menu()

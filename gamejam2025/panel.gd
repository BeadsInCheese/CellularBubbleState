extends Panel

@export
var settings :Settings

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_mouse_entered() -> void:
	print("3")
	$VBoxContainer.show()

func _on_mouse_exited() -> void:
	print("4")
	$VBoxContainer.hide()


func _on_button_4_button_down() -> void:
	Settings.setMaster(0)


func _on_button_button_down() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()

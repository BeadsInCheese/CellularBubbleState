extends Node2D

@export
var board:Board=null
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		print("test "+str(event.position))
		
	
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
		get_tree().quit()
		
	if Input.is_key_pressed(KEY_M):
		if Settings.masterVolume == 0:
			Settings.setMaster(80)
		else:
			Settings.setMaster(0)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

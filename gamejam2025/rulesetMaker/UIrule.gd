extends Panel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
var rule
var ruleName
var result

var hovered=false
func _on_delete_button_pressed() -> void:
	queue_free()


func _on_mouse_entered() -> void:
	hovered=true


func _on_mouse_exited() -> void:
	hovered=false

extends Control
@export
var opponent:int
signal buttonPressed(opponent)


# Called when the node enters the scene tree for the first time.
func emitBtnPressed():
	emit_signal("buttonPressed",opponent)
	$Btn.disabled=true
func _ready() -> void:
	$Btn.connect("button_down",emitBtnPressed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

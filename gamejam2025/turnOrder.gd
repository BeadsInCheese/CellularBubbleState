extends TextureRect


# Called when the node enters the scene tree for the first time.
func update_turn():
	material.set_shader_parameter("index",get_parent().currentTurn)
func _ready() -> void:
	material.set_shader_parameter("index",0)
	get_parent().turnChangedSignal.connect(update_turn)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

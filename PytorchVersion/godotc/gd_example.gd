extends GDExample


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	modelAddLinear("fw1", "relu", 2, 4)
	modelAddLinear("fc2", "relu", 4, 1)    # Layer 2: 4 → 1
	createSession([]) # No need to pass unused array
	#train(1500,[[0.0, 0.0], [0.0, 1.0], [1.0, 0.0], [1.0, 1.0]],[[0.0], [1.0], [1.0], [0.0]]) 
	#model_save("nknjhj")
	model_load("nknjhj")
	predict([[0.0, 0.0], [0.0, 1.0], [1.0, 0.0], [1.0, 1.0]])
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

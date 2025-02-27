extends Node
class_name Instruction

var x
var y
var value_change

func get_list(R,n):
	#TODO use R in I generation
	var list = []
	for i in range(0,n):
		var object = Instruction.new()
		object.x = randi() % 3
		object.y = randi() % 3
		object.value_change = randf_range(-10,10)
		list.append(object)
	
	return list
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

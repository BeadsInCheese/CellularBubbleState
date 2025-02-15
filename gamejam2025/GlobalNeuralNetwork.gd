extends Node

var nnas: NeuralNetworkAdvanced = NeuralNetworkAdvanced.new(NeuralNetworkAdvanced.methods.SGD)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	nnas.from_dict(loadNetwork())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func loadNetwork():
	var file = FileAccess.open("res://network.json", FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if parse_result == OK:
			var data_dict = json.data
			return data_dict
			print(data_dict)
		else:
			print("Error parsing JSON: ", parse_result)
	else:
		print("File not found")

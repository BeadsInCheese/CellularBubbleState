extends AgentBase
class_name NNAgent


# Called when the node enters the scene tree for the first time.

# Called when the node enters the scene tree for the first time.
var nnas: NeuralNetworkAdvanced = NeuralNetworkAdvanced.new(NeuralNetworkAdvanced.methods.SGD)

func init(board:Board):
	print("hi")

	nnas.learning_rate = 0.001
	nnas.add_layer(144)
	nnas.add_layer(30, "LEAKYRELU")
	nnas.add_layer(30, "LEAKYRELU")
	nnas.add_layer(1, "LINEAR")

	nnas.clip_value = 10.0
	nnas.save("res://network.json")
	nnas.from_dict(loadNetwork())
# Called every frame. 'delta' is the elapsed time since the previous frame.
func preprocess(arr)->Array:
	#print(len(arr))
	var result=[]
	for i in arr:
		result.append(i.tileType)
	return result
func sortByScore(a,b)->bool:
	return a[0]>b[0]

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

func makeMove(observation:Board):
	var scores=[]
	for i in range(len(observation.gridList)):
		if(observation.gridList[i].tileType==0):
			var temp=preprocess(observation.gridList)
			temp[i]=playerType
			scores.append([nnas.predict(temp),i])
	nnas.train(preprocess(observation.gridList),[1.0])
	scores.sort_custom(sortByScore)
	observation.gridList[scores[0][1]].setTileType(playerType)
	#print(scores)
	#makeRandomMove(observation)
func _process(delta: float) -> void:
	pass

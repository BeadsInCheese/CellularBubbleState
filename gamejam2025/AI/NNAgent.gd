extends AgentBase
class_name NNAgent


# Called when the node enters the scene tree for the first time.

# Called when the node enters the scene tree for the first time.
var nnas: NeuralNetworkAdvanced = NeuralNetworkAdvanced.new(NeuralNetworkAdvanced.methods.SGD)
var training=true
func destructor(observation:Board):
	if(training):
		nnas.train(preprocess(observation.gridList),[observation.victor])
		
func init(board:Board):
	print("hi")

	nnas.learning_rate = 0.001
	nnas.add_layer(144)
	nnas.add_layer(30, "LEAKYRELU")
	nnas.add_layer(30, "LEAKYRELU")
	nnas.add_layer(1, "SIGMOID")

	nnas.clip_value = 10.0
	nnas.from_dict(loadNetwork())
# Called every frame. 'delta' is the elapsed time since the previous frame.
func preprocess(arr)->Array:
	#print(len(arr))
	var result=[]
	for i in arr:
		result.append(i.tileType/4.0)
	return result
func AsortByScore(a,b)->bool:
		return a[0][0]>b[0][0]
func BsortByScore(a,b)->bool:
		return a[0][0]<b[0][0]
func onTrainEnd(history,label):
	trainer.realtimeTrain(nnas,history,label)
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
var best
func evaluateBest(observation:Board):
	var scores=[]
	for i in range(len(observation.gridList)):
		if(observation.gridList[i].tileType==0):
			var temp=preprocess(observation.gridList)
			temp[i]=playerType/4.0
			var val=nnas.predict(temp)
			val[0]+=0.3*randfn(0,0.5)
			scores.append([val,i])
	if(playerType==1):
		scores.sort_custom(AsortByScore)
	else:
		scores.sort_custom(BsortByScore)
	best=scores[0][1]
func makeMove(observation:Board):
	var thread = Thread.new()

	thread.start(evaluateBest.bind(observation))
	while thread.is_alive():
		await observation.get_tree().process_frame
	thread.wait_to_finish()
	observation.gridList[best].setTileType(playerType)
	#print(scores)
	#makeRandomMove(observation)
func _process(delta: float) -> void:
	pass

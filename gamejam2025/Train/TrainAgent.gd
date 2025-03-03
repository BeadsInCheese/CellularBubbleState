extends Node2D

class_name trainer
var nnas: NeuralNetworkAdvanced = NeuralNetworkAdvanced.new(NeuralNetworkAdvanced.methods.SGD)
var training=true

func preprocess(arr)->Array:
	#print(len(arr))
	var result=[]
	for i in arr:
		result.append(i.tileType)
	return result
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
static func convertToInt(data):
	var board=[]
	for i in range(0,data.length()):
		#print(data[i ])
		#print(data[i])
		board.append(int(data[i]))
	return board

static func loadDataStrings():
	var trainingData=[]
	var path="Train/TrainingData"
	var files:DirAccess=DirAccess.open(path)
	files.list_dir_begin()
	var fileName=files.get_next()
	print("file: "+fileName)
	while fileName!="":
		var file = FileAccess.open(path+"/"+fileName,FileAccess.READ)
		print(fileName)
		var label=int(fileName.substr(0,1))
		print(label)
		while not(file.eof_reached()):
			var line=file.get_line()
			if line=="":
				print("Empty line skipping")
				continue
			#print("line is: "+line)
			#print(line.substr(0,len(line)-1))
			var xData=decode(line.substr(0,len(line)-1))

			var dx = convertToInt(xData)
			#print(dx)
			trainingData.append([dx,label])
		fileName=files.get_next()
	return trainingData
		
	pass
static func decode(data):
	return DataUtility.decode(data)
static func delete_folder_contents(directory_path: String):
	var dir = DirAccess.open(directory_path)
	for file in dir.get_files():
		dir.remove(file)
func train(x,y):
	nnas.train(x,y)
		
# Called when the node enters the scene tree for the first time.
static func accuracy(y_true, y_pred) -> float:
	var correct = 0
	for i in range(y_true.size()):
		if (y_pred[i] >= 0.5 and y_true[i] == 1) or (y_pred[i] < 0.5 and y_true[i] == 0):
			correct += 1
	return float(correct) / y_true.size()
func _ready() -> void:
	nnas.learning_rate = 0.001
	nnas.add_layer(144)
	nnas.add_layer(60, "LEAKYRELU")
	nnas.add_layer(30, "LEAKYRELU")
	nnas.add_layer(1, "SIGMOID")

	nnas.clip_value = 10.0
	#nnas.from_dict(loadNetwork())
	var data=loadDataStrings()
	var offset=0
	var subsamples=[]
	for i in range(len(data)/144):
		subsamples.append(data[offset*144+(randi()%144)])
	data=subsamples
	data.shuffle()
	
	var epocs=3
	for i in range(epocs):
		var epoch_acc = 0.0
		var num_samples = 0
		for d in data:
			if(len(d[0])==144):
				var dn=normalize(d[0],4)
				nnas.train(dn,[d[1]])
				var y_pred = nnas.predict(dn)
				epoch_acc += accuracy([d[1]], y_pred)
				num_samples += 1
		print("Epoch: ", i, " Loss: "," Accuracy: ", epoch_acc / num_samples)
	nnas.save("res://network.json")
	pass # Replace with function body.
static func normalize(data,m):
	for i in range(len(data)):
		data[i]/=m
	return data
static func parseData(history,label):
	var trainingData=[]
	for i in history:
		var xData=decode(i.substr(0,len(i)-1))
		
		var dx = convertToInt(xData)
		#print(dx.size())
		#print(dx)
		trainingData.append([dx,label])
	return trainingData
static func realtimeTrain(nnas,history,label):
	var epocs=1
	#var data=loadDataStrings()
	var data=parseData(history, label)
	var offset=0
	var subsamples=[]
	print("datalen: ",len(data)/144)
	for i in range(2):
		subsamples.append(data[(randi()%len(data))])

	data=subsamples
	data.shuffle()
	print("data is of form :",data[0])
	for i in range(epocs):
		var epoch_acc = 0.0
		var num_samples = 0
		for d in data:
			if(len(d[0])==144):
				var dn=normalize(d[0],4)
				nnas.train(dn,[d[1]])
				var y_pred = nnas.predict(dn)
				print("Epoch: ", i, y_pred,d[1])
				#epoch_acc += accuracy([d[1]], y_pred)
				num_samples += 1
			else:
				print("invalid move :",d[0])
				
	nnas.save("res://network.json")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

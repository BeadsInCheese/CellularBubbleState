extends Node
class_name DataUtility

static var l = ['A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z']
static var l2 = ['a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z']

static func get_saves() -> Array[String]:
	var file2 = FileAccess.open("res://Saves/saves_data", FileAccess.READ)
	var D : Array[String] = []
	
	while(file2.get_position() < file2.get_length()):
		var str = file2.get_line()
		D.append(str)

	file2.close()
	return D

static func get_board_string(b : Array[Bubble], currentTurn):
	var str = compute_format(b) + str(currentTurn)
	return str
	

static func save_to_file(b : Array[String], title : String):
	var file = FileAccess.open("res://Saves/save-"+title, FileAccess.WRITE)
	
	for i in range(len(b)):
		file.store_line(b[i])
	
	file.close()
	
	var file3 = FileAccess.open("res://Saves/saves_data", FileAccess.READ_WRITE)
	file3.seek_end()
	file3.store_line(title)
	file3.close()
	
static func load_from_file(index) -> Array[String]:
	var lines : Array[String] = []
	var saves = get_saves()
	if(len(saves) < index):
		return lines
	else:
		#var file = FileAccess.open("res://Saves/"+saves[i],FileAccess.READ)
		var file = FileAccess.open("res://Saves/save-"+saves[index],FileAccess.READ)
		lines = []
		
		while(file.get_position() < file.get_length()):
			var str = file.get_line()
			lines.append(str)
	
	return lines
	

static func compute_format(b : Array[Bubble]):
	
	var L = []
	var sum = 0
	for i in range(12):
		for j in range(12):
			sum += b[12*i + j].tileType * 5 ** j
		L.append(sum)
		sum = 0

	
	var V = []
	for i in range(12):
		if(L[i] == 0):
			V.append(8)
		else:
			V.append(9 - ceili(log(L[i] + 0.5) / log(10)))

	
	var s = ""
	for i in range(12):
		s += str(L[i])
	
	for i in range(12):
		s += str(V[i])
			
	
	
	print("test decode:",decode(char_map(s)))
	
	
	
	return char_map(s)
	
static func char_map(s):
	
	
	var sine_transform = ""
	for i in range(0,len(s),2):
		var n
		if(i == len(s) - 1):
			sine_transform += s[i]
			break
		else:
			n = int(s.substr(i,2))
		
		if(n >= 0 && n < len(l)):
			sine_transform += l[n]
		elif(n >= len(l) && n < 2*len(l)):
			sine_transform += l2[n-len(l)]
		else:
			sine_transform += str(n)
			
	return sine_transform

static func decode(s):
	var temp = ""
	var L = []
	var output = ""
	
	var i = 0
	while i < len(s):
		if(l.find(s[i]) != -1):
			if(int(l.find(s[i])) < 10):
				temp += "0"
			temp += str(l.find(s[i]))
		elif (l2.find(s[i]) != -1):
			temp += str(l2.find(s[i]) + 26)
		else:
			if(i == len(s)-1):
				temp += s[i]
			else:
				temp += s[i] + s[i+1]
			
			i += 1
		
		i += 1
		
	var b_data = temp.substr(0,len(temp)-12)
	var offsets = temp.substr(len(b_data),12)

	var j = 0
	var c = 0
	while c < len(b_data):
		L.append(int(b_data.substr(c,9 - int(offsets[j]))))
		c += 9 - int(offsets[j])
		j += 1
	
	for m in range(len(L)):
		var n : int = L[m]
		var h = 0

		while(n >= 1):
			output += str(n % 5)
			n = n / 5
			h += 1
		for k in range(12 - h):
			output += "0"
		h = 0
	
	return output

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

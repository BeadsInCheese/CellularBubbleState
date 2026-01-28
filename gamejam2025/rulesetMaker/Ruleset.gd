
class_name ruleSet
var rules:Dictionary={}
var name:String
class rule:
	var pattern:Array
	var result:int
	var index:int

	func _init(pattern:Array,result:int,index:int) -> void:
		self.pattern=pattern
		self.result=result
		self.index=index
	func toDic():
		return {"pattern":pattern,"result": result,"index":index}
func addRule(ruleName:String,pattern:Array,result:int ):
	if(!rules.has(ruleName)):
		rules[ruleName]=rule.new(pattern,result,rules.keys().size())
	else:
		rules[ruleName]=rule.new(pattern,result,rules[ruleName].index)
func getAsArray():
	var arr=[]
	arr.resize(rules.keys().size())
	for i in rules.keys():
		arr[rules[i].index]=[rules[i].pattern,rules[i].result]
	return arr
func toDic():
	var dic={}
	for i in rules.keys():
		dic[i]=rules[i].toDic()
	return dic
func swap(a:int,b:int):
	for i in rules.keys():
		if(rules[i].index==a):
			rules[i].index=b
		elif(rules[i].index==b):
			rules[i].index=a
func swapByKey(a:String,b:String):
	var temp=rules[b].index
	rules[a].index=rules[b].index
	rules[b].index=temp
func serialize():
	return JSON.stringify(toDic())
func arrToIntArr(arr):
	var result=[]
	for i in arr:
		result.append(int(i))
	return result
func get_name_from_path(path:String):
	var str=""
	for i in path:
		if(i=="/"||i=="\\"):
			str=""
		elif(i=="."):
			return str
		else:
			str+=i
		

func load_from_file(src:String):
	name=get_name_from_path(src)
	var file = FileAccess.open(src, FileAccess.READ)
	deserialize(file.get_as_text())
	file.close()
	
func deserialize(src:String):
	var dic=JSON.parse_string(src)
	for i in dic.keys():
		addRule(i,arrToIntArr(dic[i]["pattern"]),int(dic[i]["result"]))

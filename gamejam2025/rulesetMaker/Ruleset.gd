
class_name ruleSet
var rules:Dictionary={}
class rule:
	extends Object
	var pattern:Array
	var result:int
	var index:int
	func _init(pattern:Array,result:int,index:int) -> void:
		self.pattern=pattern
		self.result=result
	func toDic():
		return {"pattern":pattern,"result": result,"index":index}
func addRule(ruleName:String,pattern:Array,result:int ):
	rules[ruleName]=rule.new(pattern,result,rules.keys().size())
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
func deserialize(src:String):
	var dic=JSON.parse_string(src)
	for i in dic.keys():
		addRule(i,dic[i]["pattern"],dic[i]["result"])

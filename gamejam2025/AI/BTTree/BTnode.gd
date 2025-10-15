extends Resource
class_name BTNode
@export var children:Array[BTNode]

func evaluate(observation:Board,playerType)->bool:
	for i in children:
		if(await i.evaluate(observation,playerType)):
			return true
	return false

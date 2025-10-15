class_name BTConditionNode
extends BTNode

enum condition{
	BOARD_EMPTY,CAN_SPAWN_MORE_THAN_TWO
	
}
func BOARD_EMPTY(observation:Board,playerType)->bool:
	for i in observation.gridList:
		if i.tileType!=0:
			return false
	return true
	
static var moveCacheIndex:int=0
func CAN_SPAWN_MORE_THAN_TWO(observation:Board,playerType)->bool:
	
	#.automataAgent.simulateAutomataStep(tempBoard)
	var prevPoints:int=0
	var newPoint:int=0
	var MoveScore:int=0
	var bestScore:int=1
	var found:bool=false
	for j in range(observation.gridList.size()):
		if observation.gridList[j].tileType!=0:
			continue
		var dup=observation.getBoardCopy()
		var dup2=observation.getBoardCopy()
		dup[j]=playerType
		observation.automataAgent.simulateAutomataStep(dup)
		observation.automataAgent.simulateAutomataStep(dup2)
		MoveScore=0
		prevPoints=0
		newPoint=0
		for i in range(dup.size()):
			if dup[i]==playerType+1:
				newPoint+=1
			elif dup2[i]==playerType+1:
				prevPoints+=1
			elif dup[i]==(playerType+2)%4+1:
				newPoint-=1
			elif dup2[i]==(playerType+2)%4+1:
				prevPoints-=1
		MoveScore=newPoint-prevPoints
		if MoveScore>bestScore:
			print(MoveScore)
			moveCacheIndex=j
			bestScore=MoveScore
			found=true
	return found
func evaluateCondition(observation:Board,playerType)->bool:
	if cond==condition.BOARD_EMPTY:
		return BOARD_EMPTY(observation,playerType)
	if cond==condition.CAN_SPAWN_MORE_THAN_TWO:
		return CAN_SPAWN_MORE_THAN_TWO(observation,playerType)
	return true
@export var cond:condition
func evaluate(observation:Board,playerType)->bool:
	if !evaluateCondition(observation,playerType):
		print("CONDITION "+str(condition.keys()[cond])+" FALSE")
		return false
	print("CONDITION "+str(condition.keys()[cond])+" TRUE")
	for i in children:
		if(await i.evaluate(observation,playerType)):
			return true
	return false

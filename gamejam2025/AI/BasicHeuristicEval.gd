extends "res://AI/AgentBase.gd"

class_name Heuristic
var aa_cache
var ob:Board
func calcFromPos(index:int,boardX:int)->Vector2:
	return Vector2(index%boardX,floor(index/boardX))
func CAN_SPAWN_MORE_THAN_TWO(observation:Array)->int:
	#.automataAgent.simulateAutomataStep(tempBoard)
	var prevPoints:int=0
	var newPoint:int=0
	var MoveScore:int=0
	var bestScore:int=1
	var found:bool=false
	aa_cache.simulateAutomataStep(observation)
	aa_cache.simulateAutomataStep(observation)
	MoveScore=0
	prevPoints=0
	newPoint=0
	for i in range(observation.size()):
			if observation[i]==playerType:
				newPoint+=1
			elif observation[i]==playerType+1:
				newPoint+=8
			elif observation[i]==(playerType+3)%5+floor((playerType+3)/5):
				prevPoints-=2
			elif observation[i]==(playerType+2)%5+floor((playerType+2)/5):
				prevPoints-=1
	return (newPoint-prevPoints)
func center_heuristic(observation:Array):
	aa_cache.simulateAutomataStep(observation)
	aa_cache.simulateAutomataStep(observation)
	var score=0
	for i in range(observation.size()):
		if(observation[i]!=0):
			
			var l=(ob.xsize/2-(Vector2(ob.xsize/2,ob.ysize/2)-calcFromPos(i,ob.xsize)).length())/(ob.xsize/4)
			
			if observation[i]==playerType:
				score-=l
			elif observation[i]==playerType+1:
				score-=l
			elif observation[i]==(playerType+2)%5+floor((playerType+2)/5):
				score+=l
			elif observation[i]==(playerType+3)%5+floor((playerType+2)/5):
				score+=l
	#print("score :"+str(score))
	return -score
var heuristics:Array[Callable]=[CAN_SPAWN_MORE_THAN_TWO,center_heuristic]
func test_heuristics(b:Array)->int:
	var val=0
	for i in heuristics:
		val+=i.call(b)
	return val
func makeMove(observation:Board):
	var offset=0
	await observation.get_tree().create_timer(0.10).timeout
	var best_move:int
	var best_score:int=-99999999
	aa_cache=observation.automataAgent
	ob=observation
	for i in len(observation.gridList):
		if(observation.gridList[i].tileType==0):
			var dup=observation.getBoardCopy()
			dup[i]=playerType
			var val=test_heuristics(dup)
			if(best_score<=val):
				best_move=i
				best_score=val
	observation.gridList[(best_move)].setTileType(playerType)
	moveMade.emit(observation)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func get_custom_class_name():
	return "HeuristicAI"

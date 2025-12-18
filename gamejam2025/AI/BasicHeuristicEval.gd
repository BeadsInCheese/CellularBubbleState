extends "res://AI/AgentBase.gd"

class_name Heuristic
var aa_cache
var ob:Board
func calcFromPos(index:int,boardX:int)->Vector2:
	return Vector2(index%boardX,floor(index/boardX))
func calcToPos(index:Vector2,boardX:int)->int:
	return index.y*boardX+index.x
func diagonal_heuristic(observation:Array,tileToEvaluate)->int:
	var offsets:Array[Vector2]=[Vector2(1,1),Vector2(-1,-1),Vector2(-1,1),Vector2(1,-1)]
	var offsets2:Array[Vector2]=[Vector2(1,0),Vector2(-1,0),Vector2(0,1),Vector2(0,-1)]
	var score=0
	#print(playerType)
	for i in offsets:
		var offsetTile = calcToPos(i+calcFromPos(tileToEvaluate,ob.xsize),ob.xsize)
		if(offsetTile<observation.size()):
			if(observation[offsetTile]==playerType):
				score+=4
	for i in offsets2:
		var offsetTile = calcToPos(i+calcFromPos(tileToEvaluate,ob.xsize),ob.xsize)
		if(offsetTile<observation.size()):
			if(observation[offsetTile]==playerType+1):
						score+=1
			if(observation[offsetTile]==(playerType+2)%5+floor((playerType+2)/5)):
						score-=3
	return score
	

func CAN_SPAWN_MORE_THAN_TWO(observation:Array,tileToEvaluate)->int:
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
	#Calculate difference in points for both players
	for i in range(observation.size()):
			if observation[i]==playerType:
				newPoint+=15
			elif observation[i]==playerType+1:
				newPoint+=30
			elif observation[i]==(playerType+3)%5+floor((playerType+3)/5):
				prevPoints+=12
			elif observation[i]==(playerType+2)%5+floor((playerType+2)/5):
				prevPoints+=6
	return (newPoint-prevPoints)
func center_heuristic(observation:Array,tileToEvaluate)->int:
	#aa_cache.simulateAutomataStep(observation)
	#aa_cache.simulateAutomataStep(observation)
	var score=0
	var count=1
	for i in range(observation.size()):
		if(observation[i]!=0):
			
			var distanceToCenter=(((Vector2(ob.xsize/2,ob.ysize/2)-calcFromPos(i,ob.xsize)).length()))
			
			if observation[i]==playerType:
				score+=distanceToCenter
			elif observation[i]==playerType+1:
				score+=distanceToCenter
			elif observation[i]==(playerType+2)%5+floor((playerType+2)/5):
				score-=distanceToCenter
			elif observation[i]==(playerType+3)%5+floor((playerType+2)/5):
				score-=distanceToCenter
			count+=1
			#print(l," calc ",calcFromPos(i,ob.xsize))
	return -score
	
var heuristics:Array[Callable]=[center_heuristic,diagonal_heuristic,CAN_SPAWN_MORE_THAN_TWO]
func test_heuristics(tileToEvaluate:int)->int:
	var val=0
	for i in heuristics:
		var dup=ob.getBoardCopy()
		dup[tileToEvaluate]=playerType
		val+=i.call(dup,tileToEvaluate)
	return val

func makeMove(observation:Board):
	var offset=0
	await observation.get_tree().create_timer(0.1).timeout
	if(!Board.boardExists):
		return
	var best_move:int
	var best_score:int=-99999999
	aa_cache=observation.automataAgent
	ob=observation
	for i in len(observation.gridList):
		if(observation.gridList[i].tileType==0):
			var val=test_heuristics(i)
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

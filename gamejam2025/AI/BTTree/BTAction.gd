extends BTNode
class_name BTAction
enum action{
	RANDOM_MOVE,
	PLAY_CACHED_MOVE,
	PLAY_DIAGONAL,
	PLACE_CENTER
}

func calcFromPos(index:int,boardX:int)->Vector2:
	return Vector2(index%boardX,floor(index/boardX))
func calcToPos(index:Vector2,boardX:int)->int:
	return index.y*boardX+index.x
@export var act:action

func placeDiagonal(i:int,offset:Vector2,observation:Board,playerType):
	var pos=calcFromPos(i,observation.xsize)
	var topIndex=calcToPos(pos+offset,observation.xsize)
	if(topIndex>=0&&topIndex<observation.gridList.size()):
		if(observation.gridList[topIndex].tileType==0):
			await observation.get_tree().create_timer(0.10).timeout
			observation.gridList[topIndex].setTileType(playerType)
			print(str(i)+":"+str(topIndex))
			return true
	return false
func doActionOrFail(observation:Board,playerType)->bool:
	if(act==action.RANDOM_MOVE):
		var x=randi()%100
		var offset=0
		await observation.get_tree().create_timer(0.10).timeout
		for i in range(x):
			while(observation.gridList[(i+offset)%len(observation.gridList)].tileType!=0):
				offset+=1
				if(offset>100000):
					return false
		observation.gridList[(x+offset-1)%len(observation.gridList)].setTileType(playerType)
		print("ACTION RANDOM")
		return true
	if(act==action.PLAY_CACHED_MOVE):
		if observation.gridList[BTConditionNode.moveCacheIndex].tileType==0:
			await observation.get_tree().create_timer(0.10).timeout
			observation.gridList[BTConditionNode.moveCacheIndex].setTileType(playerType)
			return true
		else:
			print("Cached move failed")
			return false

	if(act==action.PLAY_DIAGONAL):
		var offsets:Array[Vector2]=[Vector2(1,1),Vector2(-1,-1),Vector2(-1,1),Vector2(1,-1)]
		for i in range(observation.gridList.size()):
			print("checking square...")
			if(observation.gridList[i].tileType==playerType):
				offsets.shuffle()
				for j in range(offsets.size()):
					if(await placeDiagonal(i,offsets[j],observation,playerType)):
						return true
		print("FAILED TO FIND DIAGONAL")
		return false
	if(act==action.PLACE_CENTER):
		var mindist=10000
		var selected=null
		var found=false
		for i in range(observation.gridList.size()):
			if(observation.gridList[i].tileType==0):
				var l=(Vector2(observation.xsize/2,observation.ysize/2)-calcFromPos(i,observation.xsize)).length_squared()
				if(l<mindist):
					selected=i
					mindist=l
					found=true
		if found:
			await observation.get_tree().create_timer(0.10).timeout
			observation.gridList[selected].setTileType(playerType)
			return true
	return false
func evaluate(observation:Board,playerType)->bool:
	print("TRY ACTION "+str(action.keys()[act]))
	return await doActionOrFail(observation,playerType)

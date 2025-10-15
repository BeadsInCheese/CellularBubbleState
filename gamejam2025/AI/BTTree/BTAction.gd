extends BTNode
class_name BTAction
enum action{
	RANDOM_MOVE,
	PLAY_CACHED_MOVE,
	PLAY_DIAGONAL
}

func calcFromPos(index:int,boardX:int)->Vector2:
	return Vector2(index%boardX,floor(index/boardX))
func calcToPos(index:Vector2,boardX:int)->int:
	return index.y*boardX+index.x
@export var act:action
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
	return false
	if(act==action.PLAY_DIAGONAL):
		for i in range(observation.gridList.size()):
			if(observation.gridList[i].tileType==playerType):
				var pos=calcFromPos(i,observation.xsize)
				var topIndex=calcToPos(pos+Vector2(1,1),observation.xsize)
				if(topIndex>=0&&topIndex<observation.gridList.size()):
					if(observation.gridList[topIndex].tileType==0):
						await observation.get_tree().create_timer(0.10).timeout
						observation.gridList[topIndex].setTileType(playerType)
						print(str(i)+":"+str(topIndex))
						return true
				var botIndex=calcToPos(pos+Vector2(-1,-1),observation.xsize)
				if(botIndex>=0&&botIndex<observation.gridList.size()):
					if(observation.gridList[botIndex].tileType==0):
						await observation.get_tree().create_timer(0.10).timeout
						observation.gridList[botIndex].setTileType(playerType)
						print(str(i)+":"+str(botIndex))
						return true
				topIndex=calcToPos(pos+Vector2(-1,1),observation.xsize)
				if(topIndex>=0&&topIndex<observation.gridList.size()):
					if(observation.gridList[topIndex].tileType==0):
						await observation.get_tree().create_timer(0.10).timeout
						observation.gridList[topIndex].setTileType(playerType)
						print(str(i)+":"+str(topIndex))
						return true
				botIndex=calcToPos(pos+Vector2(1,-1),observation.xsize)
				if(botIndex>=0&&botIndex<observation.gridList.size()):
					if(observation.gridList[botIndex].tileType==0):
						await observation.get_tree().create_timer(0.10).timeout
						observation.gridList[botIndex].setTileType(playerType)
						print(str(i)+":"+str(botIndex))
						return true
		print("FAILED TO FIND DIAGONAL")
		return false
func evaluate(observation:Board,playerType)->bool:
	print("TRY ACTION "+str(action.keys()[act]))
	return await doActionOrFail(observation,playerType)

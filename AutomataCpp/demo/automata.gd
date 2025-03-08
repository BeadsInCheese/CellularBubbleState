extends Automata


# Called when the node enters the scene tree for the first time.
func automata_step() -> void:
	print("automata")
	var baseGrid = game_board.getBoardCopy()
	var tempGrid = baseGrid.duplicate(true)
	for i in range(len(tempGrid)):
		var xpos:int=i%game_board.xsize
		var ypos:int=i/game_board.ysize
		
		var result = checkRulesForPos(xpos, ypos, baseGrid)
		if result != -1:
			tempGrid[i] = result
	
	for i in range(len(tempGrid)):
		var currentTile = game_board.gridList[i].tileType
		var newTile = tempGrid[i]
		
		if currentTile != newTile:
			game_board.gridList[i].setTileType(newTile, true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

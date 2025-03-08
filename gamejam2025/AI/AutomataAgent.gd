extends AgentBase

class_name AutomataAgent
# Called when the node enters the scene tree for the first time.
func makeMove(observation:Board):
	game_board = observation
	automata_step()
	moveMade.emit(game_board)
static var automata:Automata=null
func init(board:Board):
	game_board=board
	automata=board.get_child(0)
	automata.printRules()
	compareProcessingTime()
func _ready() -> void:
	pass # Replace with function body.

var game_board: Board

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func get_custom_class_name():
	return "AutomataAgent"
	
func compareProcessingTime():
	var iter=1
	var baseGrid = game_board.getBoardCopy()
	var tempGrid = baseGrid.duplicate(true)
	
	var start_time: float = Time.get_unix_time_from_system()
	for k in iter:
		automata.AutomataStep(tempGrid)
	var end_time: float = Time.get_unix_time_from_system()
	var result=end_time-start_time
	print("time took: "+str(result))
	start_time = Time.get_unix_time_from_system()
	for k in iter:
		for i in range(len(tempGrid)):
			var xpos:int=i%game_board.xsize
			var ypos:int=i/game_board.ysize
			#print(len(baseGrid))
			var r = checkRulesForPos(xpos, ypos, baseGrid)#automata.checkRuleForPos(xpos, ypos, baseGrid,rules)#
			#print(result)
			if result != -1:
				tempGrid[i] = result
	end_time = Time.get_unix_time_from_system()
	result=end_time-start_time
	print("time took: "+str(result))
	
	
	
	
	
func automata_step() -> void:
	#print("automata")
	var baseGrid = game_board.getBoardCopy()
	var tempGrid = baseGrid.duplicate(true)
	var result=automata.AutomataStep(tempGrid)
	print(tempGrid)
	#for i in range(len(tempGrid)):
	#	var xpos:int=i%game_board.xsize
	#	var ypos:int=i/game_board.ysize
	#	print(len(baseGrid))
	#	var result = automata.AutomataStep(baseGrid)#checkRulesForPos(xpos, ypos, baseGrid)#automata.checkRuleForPos(xpos, ypos, baseGrid,rules)#
	#	#print(result)
	#	if result != -1:
	#		tempGrid[i] = result
	
	for i in range(len(tempGrid)):
		var currentTile = game_board.gridList[i].tileType
		var newTile = tempGrid[i]
		
		if currentTile != newTile:
			game_board.gridList[i].setTileType(newTile, true)

static func simulateAutomataStep(board:Array):
		board = automata.AutomataStep(board)
		
static func checkRulesForPosStatic(xpos: int, ypos: int, board: Array) -> int:
	for matchGrid in rules.keys():
		var grid = matchGrid
		var marks = getMarkIndexes(grid)
		
		for rot in range(4):
			var result = checkRuleStatic(grid, rules[matchGrid], xpos, ypos, marks[rot][0], marks[rot][1], board)
			if result != -1:
				return result
			if rot < 3:
				grid = rotateGrid(grid)
	return -1
static func checkRuleStatic(matchGrid: Array, matchResult: int, xpos: int, ypos: int, xmark: int, ymark: int, board: Array) -> int:
	var matchPlayer: int = 0  # 0: no-player, 1: player-1, 2: player-2
	
	for j in range(len(matchGrid[0])):
		for i in range(len(matchGrid)):
			var matchRef = matchGrid[i][j]
			
			# Ignore matches marked with "any"
			if matchRef == null:
				continue
			
			var tile = Board.getGridTileTypeStatic(12,12,i + xpos - xmark, j + ypos - ymark, board)
			#print(i, j, "  ", matchRef, "\t\t", tile)
			
			if matchRef == t:
				# Matching any tower and tile is not a tower, or matching different player tower
				if (tile != 1 and tile != 3) or (matchPlayer == 1 and tile == 3) or (matchPlayer == 2 and tile == 1):
					return -1
				
				matchPlayer = 1 if tile == 1 else 2
				
			elif matchRef == b:
				# Matching any bubble and tile is not a bubble, or matching different player bubble
				if (tile != 2 and tile != 4) or (matchPlayer == 1 and tile == 4) or (matchPlayer == 2 and tile == 2):
					return -1
				
				matchPlayer = 1 if tile == 2 else 2
			
			# Matching empty tile or specific player tile	
			elif (matchRef != tile):
				return -1
	
	# Return bubble/tower with the matched player color
	if matchResult == b:
		return 2 if matchPlayer == 1 else 4
	if matchResult == t:
		return 1 if matchPlayer == 1 else 3

	return matchResult
func checkRulesForPos(xpos: int, ypos: int, board: Array) -> int:
	for matchGrid in rules.keys():
		var grid = matchGrid
		var marks = getMarkIndexes(grid)
		
		for rot in range(4):
			var result = checkRule(grid, rules[matchGrid], xpos, ypos, marks[rot][0], marks[rot][1], board)
			if result != -1:
				return result
			if rot < 3:
				grid = rotateGrid(grid)
	return -1

func checkRule(matchGrid: Array, matchResult: int, xpos: int, ypos: int, xmark: int, ymark: int, board: Array) -> int:
	var matchPlayer: int = 0  # 0: no-player, 1: player-1, 2: player-2
	
	for j in range(len(matchGrid[0])):
		for i in range(len(matchGrid)):
			var matchRef = matchGrid[i][j]
			
			# Ignore matches marked with "any"
			if matchRef == null:
				continue
			
			var tile = game_board.getGridTileType(i + xpos - xmark, j + ypos - ymark, board)
			#print(i, j, "  ", matchRef, "\t\t", tile)
			
			if matchRef == t:
				# Matching any tower and tile is not a tower, or matching different player tower
				if (tile != 1 and tile != 3) or (matchPlayer == 1 and tile == 3) or (matchPlayer == 2 and tile == 1):
					return -1
				
				matchPlayer = 1 if tile == 1 else 2
				
			elif matchRef == b:
				# Matching any bubble and tile is not a bubble, or matching different player bubble
				if (tile != 2 and tile != 4) or (matchPlayer == 1 and tile == 4) or (matchPlayer == 2 and tile == 2):
					return -1
				
				matchPlayer = 1 if tile == 2 else 2
			
			# Matching empty tile or specific player tile	
			elif (matchRef != tile):
				return -1
	
	# Return bubble/tower with the matched player color
	if matchResult == b:
		return 2 if matchPlayer == 1 else 4
	if matchResult == t:
		return 1 if matchPlayer == 1 else 3

	return matchResult


func rotateMatchGrid(matchGrid: Array):
	var grid = matchGrid
	print(grid)
	for i in range(4):
		grid = rotateGrid(grid)
		print(grid)

static func rotateGrid(grid: Array) -> Array:
	if len(grid) == 2:
		return rotate2x2Grid(grid)
	elif len(grid) == 1:
		return rotate1x3Grid(grid)
	elif len(grid) == 3 and len(grid[0]) == 1:
		return rotate3x1Grid(grid)
	else:
		return rotate3x3Grid(grid)

static func rotate2x2Grid(grid: Array) -> Array:
	return [[grid[0][1], grid[1][1]], [grid[0][0], grid[1][0]]]

static func rotate3x1Grid(grid: Array) -> Array:
	return [[grid[2][0], grid[1][0], grid[0][0]]]
	
static func rotate1x3Grid(grid: Array) -> Array:
	return [[grid[0][0]], [grid[0][1]], [grid[0][2]]]

static func rotate3x3Grid(grid: Array) -> Array:
	var result = []
	for i in range(3):
		result.append([])
		for j in range(3):
			result[-1].append(grid[j][2-i])
	return result
	

static func getMarkIndexes(matchGrid: Array) -> Array:
	if len(matchGrid) == 2:
		return [[0,0],[1,0],[1,1],[0,1]]
	elif len(matchGrid) == 1:
		return [[0,0],[0,0],[0,2],[2,0]]
	else:
		return [[1,1],[1,1],[1,1],[1,1]]


static var o = null # shortcut for Any
static var t = -1   # shortcut for Tower
static var b = -2   # shortcut for Bubble
static var rules: Dictionary = {
	[
		[ o, 1, o],
		[ 3, 0, 3],
		[ o, 1, o]
	]: 0,
	
	[
		[ o, t, o],
		[ o, 0, o],
		[ o, t, o]
	]: b,
	[
		[t, 0, t],
	]: 0,
	
	[
		[ 2, 4],
		[ 4, o]
	]: 4,
	[
		[ 4, 2],
		[ 2, o]
	]: 2,
	
	[
		[ 0, b],
		[ t, b]
	]: b,
	[
		[ b, b],
		[ 0, t]
	]: 0,
	[
		[ 0, t],
		[ b, b]
	]: b,
	[
		[ b, 0],
		[ b, t]
	]: 0,
	
	[
		[ b, b, b],
		[ o, 0, o],
		[ o, o, o]
	]: b,
	
	[
		[0, b, t],
	]: b,
	
	[
		[ 0, t],
		[ t, b]
	]: b
}

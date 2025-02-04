extends Sprite2D

class_name Board
@export
var bubble = preload("Bubble.tscn")
@export
var gui :GUI
@export
var xsize : int = 12
@export
var ysize : int = 12

var gridList: Array[Bubble] = []
enum Players{PLAYER1=1,PLAYER2=3,AUTOMATA=0}
var turnOrder=[]
var currentTurn=0
var player1Score = 0
var player2Score = 0

var lastMove=[-1,-1]
var player1Agent=load("res://AI/PlayerAgent.gd")
var player2Agent=load("res://AI/MultiplayerAgent.gd")
var automataAgent=load("res://AI/AutomataAgent.gd").new()

var minimax: Minimax = Minimax.new(Callable(result), Callable(terminal), Callable(utility), Callable(possible_actions))

# Simulate the result of an action on the board
# Returns a new board state after applying the move
func result(minimax_board: Array, action: Array, is_adversary: bool) -> Array:
	var tempBoard = minimax_board.duplicate(true)
	tempBoard[action[0]][0] = 3 if is_adversary else 1
	automata_step_for_minimax_board(tempBoard)
	return tempBoard


# Check if the game has reached a terminal state (win/draw)
func terminal(board: Array) -> bool:
	for tile in board:
		if(tile[0] == 0):
			return false
	return true

# Evaluate the board state
func utility(board: Array, is_adversary: bool) -> float:
	var p1Score=0
	var p2Score=0
	for tile in board:
		if(tile[0] == 1 or tile[0] == 2):
			p1Score += 1
		if(tile[0] == 3 or tile[0] == 4):
			p2Score += 1
	
	return p1Score - p2Score

# Get all possible valid moves on the current board
func possible_actions(board: Array) -> Array[Array]:
	var actions: Array[Array] = []
	for i in range(len(board)):
		if board[i][0] == 0:
			actions.append([i])
	
	return actions

func isEnd()->bool:
	for i in gridList:
		if(i.tileType==0):
			return false
	return true
	
func updateScore():
	player1Score=0
	player2Score=0
	for i in gridList:
		if(i.tileType == 1 or i.tileType == 2):
			player1Score += 1
		if(i.tileType == 3 or i.tileType == 4):
			player2Score += 1

var announced=false
func changeTurn()->void:
	await turnOrder[currentTurn].makeMove(self)
	currentTurn = (currentTurn+1) % 4
	
	changeTurn()
	
	
	updateScore()
	gui.updateSidebar(currentTurn,player1Score,player2Score)
	updateCursor()
	if(!announced and isEnd()):
		announced=true
		var x = load("res://VictorAnnouncement.tscn").instantiate()
		x.get_node("Text").text="[center]DRAW[/center]" if player1Score==player2Score  else "[center]Player 1 Wins[/center]" if player1Score>player2Score else "[center]Player 2 Wins[/center]"  
		add_child(x)
var p1cursor=preload("res://CursorImages/Player1.png")
var p2cursor=preload("res://CursorImages/Player2.png")
func updateCursor():
	var new_cursor_image =p1cursor if(turnOrder[currentTurn].playerType==Players.PLAYER1) else p2cursor
	Input.set_custom_mouse_cursor(new_cursor_image, Input.CURSOR_ARROW, Vector2(15,15))
# Called when the node enters the scene tree for the first time.
var p1AgentInstance
var p2AgentInstance
func _ready() -> void:
	for i in range(xsize):
		for j in range(ysize):
			var x:Bubble=bubble.instantiate()
			x.tileType=0
			x.tileIndex=j+i*xsize
			
			add_child(x)
			gridList.append(x)


	p1AgentInstance=player1Agent.new()
	p1AgentInstance.playerType=Players.PLAYER1
	p2AgentInstance=player2Agent.new()
	p2AgentInstance.playerType=Players.PLAYER2
	await p1AgentInstance.init(self)
	await p2AgentInstance.init(self)
	print("oh oooooo")
	
	
	turnOrder.append(p1AgentInstance)
	turnOrder.append(automataAgent)
	turnOrder.append(p2AgentInstance)
	turnOrder.append(automataAgent)	
	for i in turnOrder:
		print(i.get_custom_class_name())
	moveToplace()
	updateCursor()
	changeTurn()


func moveToplace()->void:
	for i in range(len(gridList)):
		var xpos:int=i%xsize
		var ypos:int=i/ysize
		gridList[i].position=Vector2(xpos,ypos)*52+Vector2(38,38)
		
func automata_step() -> void:
	var baseGrid = getBoardCopy()
	var tempGrid = baseGrid.duplicate(true)
	for i in range(len(tempGrid)):
		var xpos:int=i%xsize
		var ypos:int=i/ysize
		
		var result = checkRulesForPos(xpos, ypos, baseGrid)
		if result != -1:
			tempGrid[i] = result
	
	for i in range(len(tempGrid)):
		var currentTile = gridList[i].tileType
		var newTile = tempGrid[i]
		
		if currentTile != newTile:
			gridList[i].setTileType(newTile)

func automata_step_for_minimax_board(minimax_board: Array) -> void:
	var board = []
	for tile in minimax_board:
		board.append(tile[0])

	var baseBoard = board.duplicate(true)
	
	for i in range(len(board)):
		var xpos:int=i%xsize
		var ypos:int=i/ysize
		
		var result = checkRulesForPos(xpos, ypos, baseBoard)
		if result != -1:
			board[i] = result
	
	for i in range(len(minimax_board)):
		var currentTile = minimax_board[i][0]
		var newTile = board[i]
		
		if currentTile != newTile:
			minimax_board[i][0] = newTile

func bot_step() -> void:
	var tempBoard = getBoardCopy()
	var minimax_board = []
	for tile in tempBoard:
		minimax_board.append([tile])
		
	var action: Array = minimax.action(minimax_board, 2)
	if len(action) == 0:
		return

	gridList[action[0]].setTileType(3)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func getBoardCopy() -> Array:
	var board = []
	board.resize(len(gridList))
		
	for i in range(len(gridList)):
		board[i] = gridList[i].tileType
	
	return board

func getGridTileType(xpos: int, ypos: int, board: Array):
	if xpos < 0 or ypos < 0 or xpos >= xsize or ypos >= ysize:
		return null

	return board[xpos + ypos * ysize]

func checkRule(matchGrid: Array, matchResult: int, xpos: int, ypos: int, xmark: int, ymark: int, board: Array) -> int:
	var matchPlayer: int = 0  # 0: no-player, 1: player-1, 2: player-2
	
	for j in range(len(matchGrid[0])):
		for i in range(len(matchGrid)):
			var matchRef = matchGrid[i][j]
			
			# Ignore matches marked with "any"
			if matchRef == null:
				continue
			
			var tile = getGridTileType(i + xpos - xmark, j + ypos - ymark, board)
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


func rotateMatchGrid(matchGrid: Array):
	var grid = matchGrid
	print(grid)
	for i in range(4):
		grid = rotateGrid(grid)
		print(grid)

func rotateGrid(grid: Array) -> Array:
	if len(grid) == 2:
		return rotate2x2Grid(grid)
	elif len(grid) == 1:
		return rotate1x3Grid(grid)
	elif len(grid) == 3 and len(grid[0]) == 1:
		return rotate3x1Grid(grid)
	else:
		return rotate3x3Grid(grid)

func rotate2x2Grid(grid: Array) -> Array:
	return [[grid[0][1], grid[1][1]], [grid[0][0], grid[1][0]]]

func rotate3x1Grid(grid: Array) -> Array:
	return [[grid[2][0], grid[1][0], grid[0][0]]]
	
func rotate1x3Grid(grid: Array) -> Array:
	return [[grid[0][0]], [grid[0][1]], [grid[0][2]]]

func rotate3x3Grid(grid: Array) -> Array:
	var result = []
	for i in range(3):
		result.append([])
		for j in range(3):
			result[-1].append(grid[j][2-i])
	return result
	

func getMarkIndexes(matchGrid: Array) -> Array:
	if len(matchGrid) == 2:
		return [[0,0],[1,0],[1,1],[0,1]]
	elif len(matchGrid) == 1:
		return [[0,0],[0,0],[0,2],[2,0]]
	else:
		return [[1,1],[1,1],[1,1],[1,1]]


var o = null # shortcut for Any
var t = -1   # shortcut for Tower
var b = -2   # shortcut for Bubble
var rules: Dictionary = {
	[
		[ 2, 4],
		[ 4, o]
	]: 0,
	[
		[ 4, 2],
		[ 2, o]
	]: 0,
	
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
		[ o, t, o],
		[ o, 0, o],
		[ o, t, o]
	]: b,
	[
		[t, 0, t],
	]: 0,
	
	[
		[ 0, t],
		[ t, b]
	]: b
}


func _on_tree_exiting() -> void:
	Input.set_custom_mouse_cursor(null)

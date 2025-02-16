extends AgentBase

class_name MinimaxAgent

# Called when the node enters the scene tree for the first time.
func makeMove(observation:Board):
	if observation == null:
		return

	game_board = observation

	minimax_step()
	moveMade.emit(game_board)
	
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func get_custom_class_name():
	return "MinimaxAgent"

var game_board: Board
var minimax: Minimax = Minimax.new(Callable(result), Callable(terminal), Callable(utility), Callable(possible_actions))

func minimax_step() -> void:
	var tempBoard = game_board.getBoardCopy()
	var minimax_board = []
	for tile in tempBoard:
		minimax_board.append([tile])
	
	var action: Array = minimax.action(minimax_board, game_board.currentTurn, 3, 20) # hard: 4, 16    medium: 3, 20
	if len(action) == 0:
		return

	game_board.gridList[action[0]].setTileType(3)
	

# Simulate the result of an action on the board
# Returns a new board state after applying the move
func result(minimax_board: Array, action: Array, player_state: String) -> Array:
	var tempBoard = minimax_board.duplicate(true)
	tempBoard[action[0]][0] = 3 if player_state.begins_with("P2") else 1
	
	if player_state.ends_with("A"):
		automata_step_for_minimax_board(tempBoard)
	
	return tempBoard


# Check if the game has reached a terminal state (win/draw)
func terminal(board: Array) -> bool:
	for tile in board:
		if(tile[0] == 0):
			return false
	return true

# Evaluate the board state
func utility(board: Array) -> float:
	var p1Score=0
	var p2Score=0
	for tile in board:
		if(tile[0] == 1 or tile[0] == 2):
			p1Score += 1
		if(tile[0] == 3 or tile[0] == 4):
			p2Score += 1

	return p1Score - p2Score

# Get all possible valid moves on the current board
func possible_actions(board: Array, max_actions: int) -> Array[Array]:
	var actions: Array[Array] = []
	for i in range(len(board)):
		if board[i][0] == 0:
			actions.append([i])
	
	if max_actions < 2 or len(game_board.latestTileIndexes) < 2:
		max_actions = 2
	
	actions.shuffle()
	if len(actions) <= max_actions: # todo: fix
		return actions

	actions.sort_custom(func(a, b): return distance_from_latest_tile_indexes(a) < distance_from_latest_tile_indexes(b))
	
	actions = actions.slice(0, max_actions)
	actions.shuffle()
	return actions

func distance_from_latest_tile_indexes(action: Array):
	var latest_indexes = game_board.latestTileIndexes.duplicate()
	
	var last_index = latest_indexes.pop_back()
	if last_index == null:
		last_index = (game_board.xsize / 2) + (game_board.ysize / 2 * game_board.ysize) # Calculate middle point index
		
	var second_last_index = latest_indexes.pop_back()
	if second_last_index == null:
		second_last_index = (game_board.xsize / 2) + (game_board.ysize / 2 * game_board.ysize)
	
	return min(manhattan_distance(action[0], last_index), manhattan_distance(action[0], second_last_index))
	
func get_xypos_for_index(index: int) -> Array[int]:
	return [index%game_board.xsize, index/game_board.ysize]

func manhattan_distance(index1: int, index2: int):
	var i1 = get_xypos_for_index(index1)
	var i2 = get_xypos_for_index(index2)
	
	return abs(i1[0] - i2[0]) + abs(i1[1] - i2[1])


func automata_step_for_minimax_board(minimax_board: Array) -> void:
	var board = []
	for tile in minimax_board:
		board.append(tile[0])

	game_board.automataAgent.game_board = game_board
	var baseBoard = board.duplicate(true)
	
	for i in range(len(board)):
		var xpos:int=i%game_board.xsize
		var ypos:int=i/game_board.ysize
		
		var result = game_board.automataAgent.checkRulesForPos(xpos, ypos, baseBoard)
		if result != -1:
			board[i] = result
	
	for i in range(len(minimax_board)):
		var currentTile = minimax_board[i][0]
		var newTile = board[i]
		
		if currentTile != newTile:
			minimax_board[i][0] = newTile

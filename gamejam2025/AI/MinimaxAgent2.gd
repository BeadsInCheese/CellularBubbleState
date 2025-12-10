extends AgentBase

class_name MinimaxAgent2


# Called when the node enters the scene tree for the first time.
func makeMove(observation: Board):
	if observation == null:
		return
		
	game_board = observation
	
	thread = Thread.new()
	thread.start(minimax_step)
	
	while thread.is_alive():
		if observation == null || observation.get_tree() == null:
			break;

		await observation.get_tree().process_frame

	thread.wait_to_finish()
	
	if game_board == null:
		return
	
	game_board.gridList[calculated_action].setTileType(playerType)
	
	moveMade.emit(game_board)
	
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func get_custom_class_name():
	return "MinimaxAgent2"

var thread: Thread
var game_board: Board
var minimax: Minimax2 = Minimax2.new(result, terminal, utility, possible_actions)

var distances_to_latest_tiles = []

var calculated_action: int

func init(board: Board):
	minimax.init_zobrist()

func minimax_step() -> void:
	var tempBoard = game_board.getBoardCopy()
	
	recalc_distances_to_latest_tiles(tempBoard)
	
	var action: Array = minimax.action(tempBoard, game_board.currentTurn, 5, 20, 2)
	if len(action) == 0:
		return

	calculated_action = action[0]


# Simulate the result of an action on the board state
# Returns the resulting board state and the separate actions made on the board by this action
func result(state: Array, action: Array, player_state: String) -> Array:
	var tempBoard = state.duplicate(true)
	var tileType = 3 if player_state.begins_with("P2") else 1
	tempBoard[action[0]] = tileType
	
	var resultActions = [[action[0], tileType, 0]] # this action and the resulting automata actions
	
	if player_state.ends_with("A"):
		var results = game_board.automataAgent.simulateAutomataStepAndReturnActions(tempBoard)
		tempBoard = results[0]
		resultActions.append_array(results[1]) # add automata actions to resultActions
	
	return [tempBoard, resultActions]


# Check if the game has reached a terminal state
func terminal(state: Array) -> bool:
	for tile in state:
		if (tile == 0):
			return false
	return true

# Evaluate the board state
func utility(state: Array) -> float:
	var p1Score=0
	var p2Score=0
	for tile in state:
		if(tile == 1 or tile == 2):
			p1Score += 1
		if(tile == 3 or tile == 4):
			p2Score += 1

	return p1Score - p2Score

# Get all possible valid moves on the current board
func possible_actions(state: Array, max_actions: int) -> Array[Array]:
	var actions: Array[Array] = []

	for i in len(state):
		if state[i] == 0:
			actions.append([i, distances_to_latest_tiles[i]])

	if max_actions < 2 or len(game_board.latestTileIndexes) < 2:
		max_actions = 2

	if len(actions) <= max_actions:
		return actions

	actions.sort_custom(func(a, b): return a[1] < b[1])
	
	actions = actions.slice(0, max_actions)
	return actions

func recalc_distances_to_latest_tiles(state: Array):
	distances_to_latest_tiles = []
	distances_to_latest_tiles.resize(len(state))
	for i in len(state):
		distances_to_latest_tiles[i] = distance_to_latest_tile_indexes(i)

func distance_to_latest_tile_indexes(action_index: int):
	var latest_indexes = game_board.latestTileIndexes.duplicate()
	
	var last_index = latest_indexes.pop_back()
	if last_index == null:
		last_index = (game_board.xsize / 2) + (game_board.ysize / 2 * game_board.ysize) # Calculate middle point index
		
	var second_last_index = latest_indexes.pop_back()
	if second_last_index == null:
		second_last_index = (game_board.xsize / 2) + (game_board.ysize / 2 * game_board.ysize)
	
	var third_last_index = latest_indexes.pop_back()
	if third_last_index == null:
		third_last_index = (game_board.xsize / 2) + (game_board.ysize / 2 * game_board.ysize)
	
	return min(manhattan_distance(action_index, last_index), manhattan_distance(action_index, second_last_index), manhattan_distance(action_index, third_last_index))
	
func get_xypos_for_index(index: int) -> Array[int]:
	return [index%game_board.xsize, index/game_board.ysize]

func manhattan_distance(index1: int, index2: int):
	var i1 = get_xypos_for_index(index1)
	var i2 = get_xypos_for_index(index2)
	
	return abs(i1[0] - i2[0]) + abs(i1[1] - i2[1])

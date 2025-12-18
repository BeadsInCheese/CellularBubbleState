extends AgentBase

class_name RandomFollowerAgent

var distances_to_latest_tiles = []
var game_board: Board

func makeMove(observation:Board):
	if observation == null or not observation.exists():
		return
	
	game_board = observation

	await observation.get_tree().create_timer(0.05).timeout
	
	if observation == null or not observation.exists():
		return
		
	var initial_state = observation.getBoardCopy()
	recalc_distances_to_latest_tiles(initial_state)
	
	var actions = possible_actions(initial_state, 1)
	
	if observation == null or not observation.exists():
		return
	
	observation.gridList[actions[0][0]].setTileType(playerType)
	moveMade.emit(observation)
	Console.instance.write("Laroy","I will follow you!")

# Get all possible valid moves on the current board
func possible_actions(state: Array, max_actions: int) -> Array[Array]:
	var actions: Array[Array] = []

	for i in len(state):
		if state[i] == 0:
			actions.append([i, distances_to_latest_tiles[i]])

	if len(actions) <= max_actions:
		return actions

	actions.shuffle()
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
	
	return manhattan_distance(action_index, last_index)

func get_xypos_for_index(index: int) -> Array[int]:
	return [index%game_board.xsize, index/game_board.ysize]

func manhattan_distance(index1: int, index2: int):
	var i1 = get_xypos_for_index(index1)
	var i2 = get_xypos_for_index(index2)
	
	return abs(i1[0] - i2[0]) + abs(i1[1] - i2[1])

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func get_custom_class_name():
	return "RandomFollowerAgent"

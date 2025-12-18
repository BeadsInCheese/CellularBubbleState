extends MinimaxStrategolAgent

class_name MinimaxGolgathAgent

func get_custom_class_name():
	return "MinimaxGolgathAgent"

func init(board: Board):
	super.init(board)

	max_actions = 18
	max_actions_decay = 2
	max_depth = 3

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

func distance_to_latest_tile_indexes(action_index: int):
	var latest_indexes = game_board.latestTileIndexes.duplicate()
	
	var last_index = latest_indexes.pop_back()
	if last_index == null:
		last_index = (game_board.xsize / 2) + (game_board.ysize / 2 * game_board.ysize) # Calculate middle point index
		
	var second_last_index = latest_indexes.pop_back()
	if second_last_index == null:
		second_last_index = (game_board.xsize / 2) + (game_board.ysize / 2 * game_board.ysize)
	
	return min(manhattan_distance(action_index, last_index), manhattan_distance(action_index, second_last_index))

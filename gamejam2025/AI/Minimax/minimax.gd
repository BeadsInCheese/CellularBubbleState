class_name Minimax

var result_func: Callable
var terminal_func: Callable
var utility_func: Callable
var possible_actions_func: Callable

var states_explored: int = 0
var max_depth: int
var max_actions_decay: int

var turn_order: Array[String] = ["P1", "P2A", "A", "P2", "P1A", "A"]

var print_count = 0

func get_next_turn_index(turn: int):
	if turn == 1: return 3
	if turn == 4: return 0
	return turn + 1

func _init(result_func: Callable, terminal_func: Callable, utility_func: Callable, possible_actions_func: Callable):
	# Initialize the minimax algorithm with game-specific functions and a depth limit.
	self.result_func = result_func
	self.terminal_func = terminal_func
	self.utility_func = utility_func
	self.possible_actions_func = possible_actions_func

func action(state: Array, current_turn: int, max_depth: int, max_actions: int, max_actions_decay: int) -> Array:
	# Find the best action from the current state using minimax with alpha-beta pruning.
	var is_adversary = turn_order[current_turn].begins_with("P2")
	
	var possible_actions: Array = possible_actions_func.call(state, max_actions)
	var optimal_action: Array
	var optimal_value: float = -INF if not is_adversary else INF
	
	self.max_depth = max_depth
	self.max_actions_decay = max_actions_decay
	var current_depth = 1

	# Initialize alpha and beta for pruning.
	var alpha: float = -INF
	var beta: float = INF
	
	#print("start", str(state), " ADVERSARY" if is_adversary else " NON-A")


	# Evaluate each possible action and update optimal values based on pruning.
	for _action in possible_actions:
		var result_state = result_func.call(state, _action, turn_order[current_turn])
		var value_of_result_state: float = self.minimax(result_state, get_next_turn_index(current_turn), alpha, beta, current_depth + 1, max_actions - max_actions_decay)
	
		#print("     ", str(result_state), " value: ", value_of_result_state, " ADVERSARY " if is_adversary else " NON-A ")
		if is_adversary:
			if value_of_result_state < optimal_value:
				optimal_action = _action
				optimal_value = value_of_result_state
			beta = min(beta, optimal_value)
		else:
			if value_of_result_state > optimal_value:
				optimal_action = _action
				optimal_value = value_of_result_state
			alpha = max(alpha, optimal_value)

		# Prune branches if alpha >= beta.
		if beta <= alpha:
			break

	return optimal_action

func minimax(state: Array, turn: int, alpha: float, beta: float, current_depth: int, max_actions: int) -> float:
	# Recursively evaluate the state using minimax with alpha-beta pruning.
	var is_adversary = turn_order[turn].begins_with("P2")
	
	if terminal_func.call(state) == true or (max_depth != -1 and current_depth > max_depth):
		# If terminal state or max depth reached, return the utility value of the state.
		return utility_func.call(state)

	var possible_actions: Array = possible_actions_func.call(state, max_actions)
	var optimal_value: float = -INF if not is_adversary else INF

	# Evaluate possible actions recursively using alpha-beta pruning.
	for _action in possible_actions:
		var result_state = result_func.call(state, _action, turn_order[turn])
		states_explored += 1

		var value_of_result_state = self.minimax(result_state, get_next_turn_index(turn), alpha, beta, current_depth + 1, max_actions - max_actions_decay)
		
		#print("--", current_depth, "- ", str(result_state), " value: ", value_of_result_state, " ADVERSARY " if _is_adversary else " NON-A ")

		if is_adversary:
			if value_of_result_state < optimal_value:
				optimal_value = value_of_result_state
			beta = min(beta, optimal_value)
		else:
			if value_of_result_state > optimal_value:
				optimal_value = value_of_result_state
			alpha = max(alpha, optimal_value)

		# Prune branches if alpha >= beta.
		if beta <= alpha:
			break

	return optimal_value

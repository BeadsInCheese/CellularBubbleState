class_name Minimax

var result_func: Callable
var terminal_func: Callable
var utility_func: Callable
var possible_actions_func: Callable

var is_adversary: bool = true
var states_explored: int = 0
var max_depth: int

var states: Dictionary = {}
var print_count = 0

func _init(result_func: Callable, terminal_func: Callable, utility_func: Callable, possible_actions_func: Callable, depth: int = -1):
	# Initialize the minimax algorithm with game-specific functions and a depth limit.
	self.result_func = result_func
	self.terminal_func = terminal_func
	self.utility_func = utility_func
	self.possible_actions_func = possible_actions_func
	self.max_depth = depth

func action(state: Array, depth: int = -1) -> Array:
	# Find the best action from the current state using minimax with alpha-beta pruning.
	var possible_actions: Array = possible_actions_func.call(state)
	var optimal_action: Array
	var optimal_value: float = -INF if not is_adversary else INF
	
	states.clear()
	max_depth = depth
	var current_depth = 1

	# Initialize alpha and beta for pruning.
	var alpha: float = -INF
	var beta: float = INF
	
	#print("start", str(state), " ADVERSARY" if is_adversary else " NON-A")
	

	# Evaluate each possible action and update optimal values based on pruning.
	for _action in possible_actions:
		var result_state = result_func.call(state, _action, is_adversary)
		var value_of_result_state: float = self.minimax(result_state, not is_adversary, alpha, beta, current_depth + 1)
	
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

func minimax(state: Array, _is_adversary: bool, alpha: float, beta: float, current_depth: int) -> float:
	# Recursively evaluate the state using minimax with alpha-beta pruning.
	if terminal_func.call(state) == true or (max_depth != -1 and current_depth > max_depth):
		# If terminal state or max depth reached, return the utility value of the state.
		return utility_func.call(state, not _is_adversary)

	var possible_actions: Array = possible_actions_func.call(state)
	var optimal_value: float = -INF if not _is_adversary else INF

	# Evaluate possible actions recursively using alpha-beta pruning.
	for _action in possible_actions:
		var result_state = result_func.call(state, _action, _is_adversary)
		states_explored += 1
		
		var value_of_result_state: float = 0.0
		var s = str(result_state) + ("A" if _is_adversary else "N")
		var stored_result = states.get(s)
		
		if stored_result != null:
			value_of_result_state = stored_result
			#print("Hit stored state: ", s, " result: ", stored_result)
		else:
			value_of_result_state = self.minimax(result_state, not _is_adversary, alpha, beta, current_depth + 1)
			states[s] = value_of_result_state
		
		#print("--", current_depth, "- ", str(result_state), " value: ", value_of_result_state, " ADVERSARY " if _is_adversary else " NON-A ")

		if _is_adversary:
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

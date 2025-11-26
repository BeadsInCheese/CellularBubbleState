class_name Minimax2

var result_func: Callable
var terminal_func: Callable
var utility_func: Callable
var possible_actions_func: Callable

var states_explored: int = 0
var max_depth: int
var max_actions_decay: int

var turn_order: Array[String] = ["P1", "P2A", "A", "P2", "P1A", "A"]

func get_next_turn_index(turn: int):
	if turn == 1: return 3
	if turn == 4: return 0
	return turn + 1

func get_previous_turn_index(turn: int):
	if turn == 3: return 1
	if turn == 0: return 4
	return turn - 1

func _init(result_func: Callable, terminal_func: Callable, utility_func: Callable, possible_actions_func: Callable):
	# Initialize the minimax algorithm with game-specific functions and a depth limit.
	self.result_func = result_func
	self.terminal_func = terminal_func
	self.utility_func = utility_func
	self.possible_actions_func = possible_actions_func
	
	seed(1)

func action(state: Array, current_turn: int, max_depth: int, max_actions: int, max_actions_decay: int) -> Array:
	# Find the best action from the current state using minimax with alpha-beta pruning.
	var is_adversary = turn_order[current_turn].begins_with("P2")
	
	var initial_zobrist_key = generate_zobrist_key(state, current_turn)
	print("initial zobr: ", initial_zobrist_key)
	
	#state[0] = 1
	#var key2 = generate_zobrist_key(state, current_turn)
	#var key2_u = update_zobrist_key([[0, 1]], initial_zobrist_key)
	
	#print(key2)
	#print(key2_u)
	
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
		var results = result_func.call(state, _action, turn_order[current_turn])
		var result_state = results[0]
		var zobrist_key = update_zobrist_key(results[1], initial_zobrist_key)
		print("i zobr: ", zobrist_key)
		print("i recalc zobr: ", generate_zobrist_key(result_state, current_turn))
		
		var value_of_result_state: float = self.minimax(result_state, get_next_turn_index(current_turn), alpha, beta, current_depth + 1, max_actions - max_actions_decay, zobrist_key)
	
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

func minimax(state: Array, turn: int, alpha: float, beta: float, current_depth: int, max_actions: int, zobrist_key: int) -> float:
	# Recursively evaluate the state using minimax with alpha-beta pruning.
	var is_adversary = turn_order[turn].begins_with("P2")
	
	if terminal_func.call(state) == true or (max_depth != -1 and current_depth > max_depth):
		# If terminal state or max depth reached, return the utility value of the state.
		return utility_func.call(state)

	var new_zobrist_key = zobrist_key
	new_zobrist_key ^= zobrist_turns[get_previous_turn_index(turn)]
	new_zobrist_key ^= zobrist_turns[turn]

	var possible_actions: Array = possible_actions_func.call(state, max_actions)
	var optimal_value: float = -INF if not is_adversary else INF

	# Evaluate possible actions recursively using alpha-beta pruning.
	for _action in possible_actions:
		var results = result_func.call(state, _action, turn_order[turn])
		var result_state = results[0]
		new_zobrist_key = update_zobrist_key(results[1], new_zobrist_key)
		print("zobr: ", new_zobrist_key)
		var new_gen_zob_key = generate_zobrist_key(result_state, turn)
		print("recalc zobr: ", new_gen_zob_key)
		states_explored += 1

		var value_of_result_state = self.minimax(result_state, get_next_turn_index(turn), alpha, beta, current_depth + 1, max_actions - max_actions_decay, new_zobrist_key)

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


var zobrist_board: Array = []
var zobrist_turns: Array[int] = []

static func random_64bit_int():
	return (randi() << 32) | randi()

func init_zobrist():
	for i in 4:
		zobrist_board.append([])
		for j in 144:
			zobrist_board[i].append(random_64bit_int())
	
	zobrist_turns.append(0) # append P1 turn as 0, so the zobrist key on turn 1 stays as 0
	for i in 5: # init other turns
		zobrist_turns.append(random_64bit_int())

func generate_zobrist_key(state: Array, turn: int) -> int:
	var key = 0
	
	for index in len(state):
		var tileType = state[index]
		if tileType != 0:
			var value = zobrist_board[tileType-1][index]
			key ^= value
	
	key ^= zobrist_turns[turn]
	
	return key

func update_zobrist_key(actions: Array, key: int) -> int:
	for action in actions:
		var value = zobrist_board[action[1]-1][action[0]]
		key ^= value
	
	return key

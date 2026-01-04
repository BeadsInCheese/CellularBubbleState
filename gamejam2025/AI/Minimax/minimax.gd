class_name Minimax

var result_func: Callable
var terminal_func: Callable
var utility_func: Callable
var possible_actions_func: Callable

var max_actions_decay: int

var result_value: float

var turn_order: Array[String] = ["P1", "P2A", "A", "P2", "P1A", "A"]

var zobrist_board: Array = []
var zobrist_turns: Array[int] = []

var transpos_eval = {}
var transpos_depth = {}
var transpos_results = {}

var start_time = 0
var timeout = false
var timeout_msec = 5000

#var states_explored = 0
#var eval_hits = 0
#var eval_misses = 0
#var alpha_beta_misses = 0

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


## Find the best action from the current state using minimax with alpha-beta pruning.
func action(state: PackedByteArray, current_turn: int, depth: int, max_actions: int, max_actions_decay: int) -> Array:
	var is_adversary = turn_order[current_turn].begins_with("P2")
	
	var initial_zobrist_key = generate_zobrist_key(state, current_turn)
	
	var optimal_action: Array
	var optimal_value: float = -INF if not is_adversary else INF
	
	self.max_actions_decay = max_actions_decay

	# Initialize alpha and beta for pruning.
	var alpha: float = -INF
	var beta: float = INF

	#alpha_beta_misses = 0
	#states_explored = 0

	# Evaluate each possible action and update optimal values based on pruning.
	for container in get_possible_action_containers(state, max_actions, initial_zobrist_key, current_turn, is_adversary):
		var result_state_eval = process_eval(container, current_turn, alpha, beta, depth, max_actions)
	
		if is_adversary:
			if result_state_eval < optimal_value:
				optimal_action = [container.index]
				optimal_value = result_state_eval
			beta = min(beta, optimal_value)
		else:
			if result_state_eval > optimal_value:
				optimal_action = [container.index]
				optimal_value = result_state_eval
			alpha = max(alpha, optimal_value)

		# Prune branches if alpha >= beta.
		if alpha >= beta:
			break
			
		if timeout or Time.get_ticks_msec() - start_time > timeout_msec:
			return []
	
	if timeout:
		return []
	
	self.result_value = optimal_value

	return optimal_action

## Recursively evaluate the state using minimax with alpha-beta pruning.
func minimax(state: PackedByteArray, turn: int, alpha: float, beta: float, current_depth: int, max_actions: int, zobrist_key: int) -> float:
	# If the board has been closed, prevent further calculations
	if not Board.boardExists or timeout:
		return 0

	# If terminal state or max depth reached, return the utility value of the state.
	if current_depth == 0 or terminal_func.call(state) == true:
		return utility_func.call(state)

	var is_adversary = turn_order[turn].begins_with("P2")

	var curr_zobrist_key = zobrist_key
	curr_zobrist_key ^= zobrist_turns[get_previous_turn_index(turn)]
	curr_zobrist_key ^= zobrist_turns[turn]

	var optimal_value: float = -INF if not is_adversary else INF
	
	#states_explored += 1

	# Evaluate possible actions recursively using alpha-beta pruning.
	for container in get_possible_action_containers(state, max_actions, curr_zobrist_key, turn, is_adversary):
		var result_state_eval = process_eval(container, turn, alpha, beta, current_depth, max_actions)

		if is_adversary:
			if result_state_eval < optimal_value:
				optimal_value = result_state_eval
			beta = min(beta, optimal_value)
		else:
			if result_state_eval > optimal_value:
				optimal_value = result_state_eval
			alpha = max(alpha, optimal_value)

		# Prune branches if alpha >= beta.
		if alpha >= beta:
			return optimal_value
			
		if Time.get_ticks_msec() - start_time > timeout_msec:
			timeout = true
			return 0
	
	#alpha_beta_misses += 1

	return optimal_value

func process_eval(container: ActionContainer, current_turn: int, alpha: float, beta: float, depth: int, max_actions: int):
	if container.stored_eval_exists and container.stored_eval_depth >= depth:
		#eval_hits += 1
		return container.stored_eval
	#else:
		#eval_misses += 1
	
	var eval = self.minimax(container.result_state, get_next_turn_index(current_turn), alpha, beta, depth - 1, max_actions - max_actions_decay, container.new_zobrist_key)
	
	if not timeout and depth > 1 and (not container.stored_eval_exists or container.stored_eval_depth < depth):
		transpos_eval[container.new_zobrist_key] = eval
		transpos_depth[container.new_zobrist_key] = depth

	return eval

#static func print_state(state: Array):
	#for j in 12:
		#var line = ""
		#for i in 12:
			#var char = str(state[i + j * 12])
			#if char == "0":
				#char = "."
			#line += char
		#print(line)

class ActionContainer:
	var index: int
	var dist_from_latest: int
	var stored_eval: float
	var stored_eval_exists: bool
	var stored_eval_depth: int
	var new_zobrist_key: int
	var result_state: PackedByteArray
	var result_actions: Array


func get_possible_action_containers(state: PackedByteArray, max_actions: int, curr_zobrist_key: int, current_turn: int, is_adversary: bool) -> Array[ActionContainer]:
	var containers: Array[ActionContainer] = []
	
	for action in possible_actions_func.call(state, max_actions):
		containers.append(get_container_for_action(action, state, curr_zobrist_key, current_turn))
	
	containers.sort_custom(func(a: ActionContainer, b: ActionContainer): 
		return ((a.stored_eval < b.stored_eval if is_adversary else a.stored_eval > b.stored_eval) 
			if a.stored_eval != b.stored_eval 
				else a.dist_from_latest < b.dist_from_latest)
	)
	
	return containers

func get_result_state_for_stored_actions(actions: Array, state: PackedByteArray) -> Array:
	var new_state = state.duplicate()
	for action in actions:
		new_state[action[0]] = action[1]

	return new_state

func get_container_for_action(action: Array, state: PackedByteArray, curr_zobrist_key: int, current_turn: int) -> ActionContainer:
	var container = ActionContainer.new()
	container.index = action[0]
	container.dist_from_latest = action[1]
	
	# get stored automata and player actions from transposition table
	var result_state
	var result_zobrist_key = curr_zobrist_key + action[0]
	var actions = transpos_results.get(result_zobrist_key)
	if actions != null:
		result_state = get_result_state_for_stored_actions(actions, state)
	else:
		var results = result_func.call(state, action, turn_order[current_turn])
		actions = results[1]
		result_state = results[0]
		
		transpos_results[result_zobrist_key] = actions

	var new_zobrist_key = update_zobrist_key(actions, curr_zobrist_key)
	
	container.new_zobrist_key = new_zobrist_key
	container.result_state = result_state
	container.result_actions = actions
	
	var eval = transpos_eval.get(new_zobrist_key)
	container.stored_eval_exists = eval != null
	if eval != null:
		container.stored_eval = eval
		container.stored_eval_depth = transpos_depth[new_zobrist_key]
	
	return container

static func random_64bit_int():
	return (randi() << 32) | randi()


func init_zobrist():
	for i in 5: # 0-empty, 1-P1, 2-P1b, 3-P2, 4-P2b
		zobrist_board.append([])
		for j in 144:
			zobrist_board[i].append(random_64bit_int() if i > 0 else 0)
	
	zobrist_turns.append(0) # append P1 turn as 0, so the zobrist key on turn 1 stays as 0
	for i in 5: # init other turns
		zobrist_turns.append(random_64bit_int())

func generate_zobrist_key(state: PackedByteArray, turn: int) -> int:
	var key = 0
	
	for index in len(state):
		var tileType = state[index]
		if tileType != 0:
			var value = zobrist_board[tileType][index]
			key ^= value
	
	key ^= zobrist_turns[turn]
	
	return key

func update_zobrist_key(actions: Array, key: int) -> int:
	for action in actions:
		key ^= zobrist_board[action[2]][action[0]] # remove old tile
		key ^= zobrist_board[action[1]][action[0]] # place new tile
	
	return key

class_name Minimax2

var result_func: Callable
var terminal_func: Callable
var utility_func: Callable
var possible_actions_func: Callable

var states_explored: int = 0
var max_depth: int
var max_actions_decay: int

var turn_order: Array[String] = ["P1", "P2A", "A", "P2", "P1A", "A"]

var zobrist_board: Array = []
var zobrist_turns: Array[int] = []

var transposEval = {}
var transposDepth = {}
var transposAutom = {}

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

## Find the best action from the current state using minimax with alpha-beta pruning.
func action(state: Array, current_turn: int, max_depth: int, max_actions: int, max_actions_decay: int) -> Array:
	var is_adversary = turn_order[current_turn].begins_with("P2")
	
	var initial_zobrist_key = generate_zobrist_key(state, current_turn)
	#print("initial zobr: ", initial_zobrist_key)
	
	var optimal_action: Array
	var optimal_value: float = -INF if not is_adversary else INF
	
	self.max_depth = max_depth
	self.max_actions_decay = max_actions_decay
	var current_depth = 1

	# Initialize alpha and beta for pruning.
	var alpha: float = -INF
	var beta: float = INF


	# Evaluate each possible action and update optimal values based on pruning.
	for container in get_possible_action_containers(state, max_actions, initial_zobrist_key, current_turn):
		states_explored += 1
		
		var result_state_eval = process_eval(container, current_turn, alpha, beta, current_depth, max_actions)
	
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
		if beta <= alpha:
			break

	return optimal_action

## Recursively evaluate the state using minimax with alpha-beta pruning.
func minimax(state: Array, turn: int, alpha: float, beta: float, current_depth: int, max_actions: int, zobrist_key: int) -> float:
	if terminal_func.call(state) == true or (max_depth != -1 and current_depth > max_depth):
		# If terminal state or max depth reached, return the utility value of the state.
		return utility_func.call(state)

	var is_adversary = turn_order[turn].begins_with("P2")

	var curr_zobrist_key = zobrist_key
	curr_zobrist_key ^= zobrist_turns[get_previous_turn_index(turn)]
	curr_zobrist_key ^= zobrist_turns[turn]

	var optimal_value: float = -INF if not is_adversary else INF

	# Evaluate possible actions recursively using alpha-beta pruning.
	for container in get_possible_action_containers(state, max_actions, curr_zobrist_key, turn):
		states_explored += 1
		
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
		if beta <= alpha:
			break

	return optimal_value


func process_eval(container: ActionContainer, current_turn: int, alpha: float, beta: float, current_depth: int, max_actions: int):
	if container.stored_eval_exists and transposDepth[container.new_zobrist_key] <= current_depth:
		return container.stored_eval
		
	var new_depth = current_depth + 1
	
	var eval = self.minimax(container.result_state, get_next_turn_index(current_turn), alpha, beta, new_depth, max_actions - max_actions_decay, container.new_zobrist_key)
	transposEval[container.new_zobrist_key] = eval
	transposDepth[container.new_zobrist_key] = new_depth
	return eval

static func print_state(state: Array):
	for j in 12:
		var line = ""
		for i in 12:
			var char = str(state[i + j * 12])
			if char == "0":
				char = "."
			line += char
		print(line)

class ActionContainer:
	var index: int
	var dist_from_latest: int
	var stored_eval: float
	var stored_eval_exists: bool
	var new_zobrist_key: int
	var result_state: Array
	var result_actions: Array
	

func get_possible_action_containers(state: Array, max_actions: int, curr_zobrist_key: int, current_turn: int) -> Array[ActionContainer]:
	var containers: Array[ActionContainer] = []
	
	for action in possible_actions_func.call(state, max_actions):
		containers.append(get_container_for_action(action, state, curr_zobrist_key, current_turn))
	
	containers.sort_custom(func(a: ActionContainer, b: ActionContainer): 
		a.stored_eval < b.stored_eval if a.stored_eval != b.stored_eval else a.dist_from_latest < b.dist_from_latest
	)
	
	return containers

func get_container_for_action(action: Array, state: Array, curr_zobrist_key: int, current_turn: int) -> ActionContainer:
	var container = ActionContainer.new()
	container.index = action[0]
	container.dist_from_latest = action[1]
	
	var results = result_func.call(state, action, turn_order[current_turn])
	var result_state = results[0]

	var new_zobrist_key = update_zobrist_key(results[1], curr_zobrist_key)
	#var new_gen_zob_key = generate_zobrist_key(result_state, current_turn)
	
	#if (new_zobrist_key != new_gen_zob_key):
		#print("recalc zobr: ", new_gen_zob_key)
		#print_state(state)
		#print("->")
		#print_state(result_state)
		#print()
	
	container.new_zobrist_key = new_zobrist_key
	container.result_state = result_state
	container.result_actions = results[1]
	
	var eval = transposEval.get(new_zobrist_key)
	container.stored_eval_exists = eval != null
	if eval != null:
		container.stored_eval = eval
	
	#print(container.action, " zobr: ", new_zobrist_key, " oldzobr:", curr_zobrist_key, "  ", states_explored, " eval: ", eval)
	
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

func generate_zobrist_key(state: Array, turn: int) -> int:
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

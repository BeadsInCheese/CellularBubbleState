extends AgentBase

class_name MinimaxAgent

# Called when the node enters the scene tree for the first time.
func makeMove(observation:Board):
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
		
	var action: Array = minimax.action(minimax_board, 1)
	if len(action) == 0:
		return

	game_board.gridList[action[0]].setTileType(3)
	

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
	
	actions.shuffle()
	return actions
	
	
func automata_step_for_minimax_board(minimax_board: Array) -> void:
	var board = []
	for tile in minimax_board:
		board.append(tile[0])

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

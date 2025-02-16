extends "res://AI/AgentBase.gd"
class_name LDAgent

var agentColor
var playerColor

var G_default_own_coeff1 : float
var G_default_own_coeff2 : float
var G_default_opponent_coeff1 : float
var G_default_opponent_coeff2 : float

var DPU_list : Array[DynamicalProcessingUnit] = []

func update(x,y,p):
	for dpu: DynamicalProcessingUnit in DPU_list:
		dpu.update(x,y,p,dpu.get_points())

func init_dpu():
	var j = 1
	for i in range(1,100):
		var u : DynamicalProcessingUnit = DynamicalProcessingUnit.new()
		u.id = i
		u.offsetX = floor(i/10) + 1
		u.offsetY = j
		u.init()
		DPU_list.append(u)
		j = (j+1) % 10

func compute_heuristic(n,color,board):
	var result = 0
	if n == 1:
		for i in range(len(board)):
			if(color == 1 && board[i].tileType == 1 || color == 3 && board[i].tileType == 3):
				result += 1.4
			elif(color == 1 && board[i].tileType == 2 || color == 3 && board[i].tileType == 4):
				result += 1
			elif(color == 1 && board[i].tileType == 3 || color == 3 && board[i].tileType == 1):
				result -= 2.8
			elif(color == 1 && board[i].tileType == 4 || color == 3 && board[i].tileType == 2):
				result -= 0.8
	elif n == 2:
		for i in range(len(board)):
			if(color == 1 && board[i].tileType == 1 || color == 3 && board[i].tileType == 3):
				result += 1
			elif(color == 1 && board[i].tileType == 2 || color == 3 && board[i].tileType == 4):
				result += 1
			elif(color == 1 && board[i].tileType == 3 || color == 3 && board[i].tileType == 1):
				result -= 1
			elif(color == 1 && board[i].tileType == 4 || color == 3 && board[i].tileType == 2):
				result -= 1
	return result

func compute_metric(n):
	pass
	
func generate_move(board : Array[Bubble]) -> int:
	
	
	var W : Array[float] = evaluate(board)
	for d : DynamicalProcessingUnit in DPU_list:
		d.update_layers(d.get_points())
		#for p : Point in d.get_points():
		#	print(p.score)
	return randi_range(0,143)
	
func evaluate(board) -> Array[float]:
	var W_COEFF = [1,2]
	var W : Array[float] = []
	var H_own = []
	var H_opponent = []
	for i in range(1,3):
		H_own.append(compute_heuristic(i,agentColor,board))
		H_opponent.append(compute_heuristic(i,playerColor,board))
		W.append(W_COEFF[i-1]*(H_own[i-1] - H_opponent[i-1]))
	return W
	
func proceduralMove(board : Board):
	var result
	var color
	 
	if board.currentTurn == 0 || board.currentTurn == 4:
		color = 1
		playerColor = 3
	elif board.currentTurn == 1 || board.currentTurn == 3:
		color = 3
		playerColor = 1

	agentColor = color

	result = generate_move(board.gridList)
	board.gridList[result].setTileType(agentColor)
	
	return board
	

func init(board):
	init_dpu()

func makeMove(observation:Board):
	await observation.get_tree().create_timer(0.5).timeout
	var game_board = proceduralMove(observation)
	moveMade.emit(game_board)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_custom_class_name():
	return "LDAgent"

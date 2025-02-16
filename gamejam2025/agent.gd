extends Node
class_name Agent

var agentColor
var playerColor

var G_default_own_coeff1 : float
var G_default_own_coeff2 : float
var G_default_opponent_coeff1 : float
var G_default_opponent_coeff2 : float

var DPU_list : Array[DynamicalProcessingUnit] = []

func update(x,y,p):
	for dpu: DynamicalProcessingUnit in DPU_list:
		dpu.update(x,y,p)

func init_dpu():
	var j = 1
	for i in range(1,100):
		var u : DynamicalProcessingUnit = DynamicalProcessingUnit.new()
		u.id = i
		u.offsetX = floor(i/10) + 1
		u.offsetY = j
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
	
func generate_move(board) -> int:
	evaluate(board)
	for d : DynamicalProcessingUnit in DPU_list:
		d.R[0].score[2]
	
func evaluate(board) -> Array[float]:
	var W_COEFF = [1,2]
	var W = []
	var H_own = []
	var H_opponent = []
	for i in range(1,3):
		H_own.append(compute_heuristic(i,agentColor,board))
		H_opponent.append(compute_heuristic(i,playerColor,board))
		W.append(W_COEFF*(H_own[i] - H_opponent[i]))
	return W
	
func proceduralMove(currentTurn,color,board) -> Bubble:
	var result
	agentColor = color
	if(color == 3):
		playerColor = 1
	elif(color == 1):
		playerColor = 3
		
	result = generate_move(board)
	
	return board[result]
	
######################################################
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

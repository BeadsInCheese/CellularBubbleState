extends "res://AI/AgentBase.gd"
class_name LDAgent

var agentColor
var playerColor

var G_default_own_coeff1 : float
var G_default_own_coeff2 : float
var G_default_opponent_coeff1 : float
var G_default_opponent_coeff2 : float
var W_target = [true,false]
var DPU_list : Array[DynamicalProcessingUnit] = []
var history = []

static var N_ROUNDS = 1200
static var DL_UNITS = 8

func init_dpu():
	var j = 1
	for k in range(0,DL_UNITS):
		for m in range(0,16):
			for i in range(0,100):
				var u : DynamicalProcessingUnit = DynamicalProcessingUnit.new()
				u.id = i + 100*m + 16*100*k
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

func update_grids(board):
	var i = 0
	while(i < 144):
		var x = i%12
		var y = i/12
		
		for j in range(x-1,x+1):
			if(j <= 0 || j >= 11):
				break
			for k in range(y-1,y+1):
				if(k <= 0 || k >= 11):
					break

				if sqrt((x-j)**2+(y-k)**2) < 1.5:
					DPU_list[j-1 + 10*(k-1)].update(j-x,k-y,board[i].tileType)

		i += 1

	
func generate_move(board : Array[Bubble]) -> int:
	var W : Array[float] = evaluate(board)
	var W_b : Array[bool] = parse(W)
	update_grids(board)
	
	for dpu: DynamicalProcessingUnit in DPU_list:
		dpu.update_layers()
	
	var n = 0
	while(n < N_ROUNDS):
		for dpu: DynamicalProcessingUnit in DPU_list:
			for p : Point in dpu.get_points():
				for layer : float in p.score:
					#history.append(p)
					var old_data : Array[Point] = []
					old_data.append(p)
					#for j in range(len(history),-1,-7):
					#	old_data.append(history[j])
					for i in len(W):
						dpu.inference_generic(p.x,p.y,layer,W[i],i,old_data)
						
						
				
				#for p1 : Point in dpu.get_points():
					#for p2 : Point in dpu.get_points():
						#
						#for layer1 : float in p1.score:
							#for layer2 : float in p2.score:
								#dpu.inference_internal(p1,p2,layer1,layer2)
								
								#d.x, d.y, layer z <-> G_xy(z)
		n += 1
		
	var j = randi() % 144
	while board[j].tileType != 0:
		j = randi() % 144

	return j
	
func parse(w_array):
	var b_array : Array[bool] = []
	for i in range(len(w_array)):
		if(w_array[i] < 0):
			b_array.append(false)
		else:
			b_array.append(true)
	return b_array
	
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
	
	print("agent is playing as: ",playerType)
	 
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

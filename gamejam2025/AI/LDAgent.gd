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
var game_board

var targetTime
static var N_ROUNDS = 1#1200
static var DL_UNITS = 1
var LOG_CLAUSE_CHAIN : Array


func init_dpu():
	var j = 1
	for k in range(0,DL_UNITS):
		for i in range(0,100):
			var u : DynamicalProcessingUnit = DynamicalProcessingUnit.new()
			u.id = i + 100*k
			u.offsetX = floor(i/10) + 1
			u.offsetY = j
			u.currentTurn = 0
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
	
	#PHASE 0: measure the position, form targets procedurally and get the clause chains for those targets
	var E : Array[Array] = evaluate(board)
	var W_b : Array[bool] = parse(E)
	var W : Array[float] = getTargets(E,targetTime)
	#var C : Array = setTriggers(E)
	for i in range(0,targetTime):
		LOG_CLAUSE_CHAIN.append(GSystem.getClause(W,i,targetTime))
	print(E)
	print(W)
	
	#PHASE 1: update DPUs
	update_grids(board)
	
	for dpu: DynamicalProcessingUnit in DPU_list:
		dpu.update_layers()

	#PHASE 2: process triggers from E & MEM_UNIT
	#MemoryUnit.triggers()
	#triggers from C are processed, settings flags, reordering DPU relevances for later phases
	
	#prepare to select DPU in the middle, if empty board
	#if(board.turn == 0):
		#for i in range(0,9):
			#var x = randi_range(3,7)
			#var y = randi_range(3,7)
			#DPU_list[x*10 + y].setLocalW(10+randf_range(-1,1))
	
	var wTime = 10
	var tTime = 1
	var n = 0
	var R_waypoints : Array
	var transitions : Array[Array]
	
	#PHASE 3: main round, solve paths for each individual DPU unit from current position to DPU_i target R_i
	while(n < N_ROUNDS):
		for dpu: DynamicalProcessingUnit in DPU_list:
			if dpu.computeRelevance() < Parameters.RELEVANCE_TLD:
				continue
			for i in len(W):
				for j in range(0,32): 
					var R = FSystem.getWaypointTarget(dpu,LOG_CLAUSE_CHAIN[i]) #create waypoint [m1,m2,nw_point,se_point] and append
					R.append(dpu.id,i,j)
					R_waypoints.append(R)
					var z_min = FSystem.computeError(dpu,R,tTime) #heptagon local search phase, 'backward inference' <-
					var TR_LIST = FSystem.generatePath(dpu,R,z_min.x,z_min.y,wTime,Vector2(dpu.get_F0(R.x),dpu.get_F0(R.y))) #find out transition chain, 'forward inference' ->
					transitions.append(TR_LIST)
		n += 1
		
		
	var moveIndex
	#rank waypoints [m1,m2,pUL,pLR,dpu_id,W_i,dpu_j] in terms of closeness to corresponding clause in clausePath
	var best = 0
	var bestIndex = 0
	#update Q_table
	#for i in range(0,1953):
	#	FSystem.Q_TABLE[i] = FSystem.computeQ(i)
	
	#PHASE 4: sort all metric pairs across DPUs (m_i,m_j) in terms of pursuit of target clauses W
	#find paths starting vectors for all best manifolds, get best waypoints' TR_LIST:s first Transition vector v'
	R_waypoints.sort_custom(computeLD)
	var bestVectors = []
	for i in range(0,Parameters.NO_WAYPOINTS):
		bestVectors.append(transitions[R_waypoints[i][3]])
	bestVectors = transitions[bestIndex]
	
	#PHASE 5: compare all available moves, optimized amongst DPU:s, to best paths starting vectors v'_j
	#return move which most closely resembles the changes of some vector in the set of best vectors
	var allMoves = getAllMoves()
	var tempBoard = board.duplicate(true)
	var closestValue = 10000

	for j in range(0,bestVectors.size()):
		var bestDPU = DPU_list[bestVectors[j][0].x / 63]
		var metric_x = bestDPU.get_points()[(bestVectors[j][0].x % 63) % 7].score[floor((bestVectors[j][0].x % 63)/7)]
		var metric_y = bestDPU.get_points()[(bestVectors[j][0].y % 63) % 7].score[floor((bestVectors[j][0].y % 63)/7)]
		var values_x = bestVectors[j][0].z
		var values_y = bestVectors[j][0].w
		var temp = 0
		for p in bestDPU.get_points():
			temp = GSystem.distance(bestDPU,p.x,p.y,metric_x,values_x) + GSystem.distance(bestDPU,p.x,p.y,metric_y,values_y)
			if temp < closestValue:
				closestValue = temp
				moveIndex = (p.x + bestDPU.offSetX - 1)*12 + p.y + bestDPU.offSetY - 1 
	return moveIndex
	

func getTargets(eval,t):
	var temp = []
	for i in range(0, eval.size()):
		#TODO actual target generation, this is placeholder for first testing of the engine
		if( eval[i][2] < 0):
			temp.append(eval[i][1] + t + randi_range(1,10))#set the target: heuristic to be higher than opponent after t turns
		else:
			temp.append(eval[i][0] + randi_range(1,6)) #set target: heuristic grows 
	return temp
	
func getAllMoves() -> Array[int]:
	var emptySquares
	for p : Bubble in game_board.gridList:
		if p.tileType == 0:
			emptySquares.append(p.tileIndex)
	return emptySquares
	
#clause-designator: [struct,expr0,expr1,...,expr_n]
func computeLD(a,b) -> bool:
	var clause_w_change = GSystem.parse(LOG_CLAUSE_CHAIN[a[5]]) #float
	var v1 = 0
	var v2 = 0
	for t in range(-2,2):
		v1 += clause_w_change - GSystem.wInft(LOG_CLAUSE_CHAIN[a[5]],a[0] % 7, (a[0]%9)%3, (a[1]%9)/3,t,0)
		v2 += clause_w_change - GSystem.wInft(LOG_CLAUSE_CHAIN[b[5]],b[0] % 7, (b[0]%9)%3, (b[1]%9)/3,t,0)
	
	if v2 - v1 > 0:
		return true
		
	return false
	
func parse(w_array):
	var b_array : Array[bool] = []
	for i in range(len(w_array)):
		if(w_array[i] < 0):
			b_array.append(false)
		else:
			b_array.append(true)
	return b_array
	
#
	
func evaluate(board) -> Array[Array]:
	var W_COEFF = [1,2]
	var T : Array[Array]
	var H_own = []
	var H_opponent = []
	
	for i in range(1,3):
		H_own.append(compute_heuristic(i,agentColor,board))
		H_opponent.append(compute_heuristic(i,playerColor,board))
		T[i-1].append(H_own[i-1])
		T[i-1].append(H_opponent[i-1])
		T[i-1].append(W_COEFF[i-1]*(H_own[i-1] - H_opponent[i-1]))
	return T
	
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
	Parameters.SEED = randi()
	#FSystem.randomize_tables(Parameters.SEED)
	#testing
	GSystem.populate()

func makeMove(observation:Board):
	#observation.get_tree().root.get_node("root/")
	await observation.get_tree().create_timer(0.5).timeout
	var game_board = proceduralMove(observation)
	moveMade.emit(game_board)

func loadData():
	#var c0File = FileAccess.open("EngineData-ldagent/c0_data",FileAccess.READ)
	var configFile = FileAccess.open("EngineData-ldagent/config",FileAccess.READ)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_custom_class_name():
	return "LDAgent"

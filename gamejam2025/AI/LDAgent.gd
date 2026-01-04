extends "res://AI/AgentBase.gd"
class_name LDAgent

var thread : Thread
var opponentType
var G_default_own_coeff1 : float
var G_default_own_coeff2 : float
var G_default_opponent_coeff1 : float
var G_default_opponent_coeff2 : float
var W_target = [true,false]
var R_waypoints : Array
var DPU_list : Array[DynamicalProcessingUnit] = []
var transitions : Array[Array]
var game_board
var result
var train = false
var debug = true


var targetTime = 10
static var N_ROUNDS = 2#1200
static var DL_UNITS = 1
#var LOG_CLAUSE_CHAIN : Array


func init_dpu():
	var j = 1
	for k in range(0,DL_UNITS):
		for i in range(0,100):
			var u : DynamicalProcessingUnit = DynamicalProcessingUnit.new()
			u.id = i + 100*k
			u.offsetX = floor(i/10) + 1
			u.offsetY = j
			u.currentTurn = 0
			u.init(playerType)
			DPU_list.append(u)
			j = (j+1) % 10

func compute_heuristic(n,color,board):
	var result = 0
	if n == 1:
		for i in range(len(board)):
			if(color == 1 && board[i].tileType == 1 || color == 3 && board[i].tileType == 3):
				result += 1
			elif(color == 1 && board[i].tileType == 2 || color == 3 && board[i].tileType == 4):
				result += 2
			elif(color == 1 && board[i].tileType == 3 || color == 3 && board[i].tileType == 1):
				result -= 1.8
			elif(color == 1 && board[i].tileType == 4 || color == 3 && board[i].tileType == 2):
				result -= 2.8
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
		
		for j in range(y-1,y+2):
			#print("j ",j)
			if(j <= 0 || j >= 11):
				continue
			for k in range(x-1,x+2):
				#print("k ",k)
				if(k <= 0 || k >= 11):
					continue
				#print("sqrt ",sqrt((x-j)**2+(y-k)**2)," x = ",x, " y = ",y, " j = ", j, " i = ",i)
				if sqrt((x-k)**2+(y-j)**2) < 1.5:
					DPU_list[k-1 + 10*(j-1)].update_point(x-k+1,y-j+1,board[i].tileType)

		i += 1



# instruction lists generation from current values of H & M
func generate_plan(heuristicValues, metricValues):
	pass
	

#meta-heuristic, decentralized move generation algorithm solving a local optimization problem of finding a best move at time 0

#R_waypoints format: [[Vector4(m1,m2,pUL,pLR),[dpu_id,W_i,dpu_j]], [Vector4(m1,m2,pUL,pLR),[dpu_id,W_i,dpu_j]]]
#transitions format: = [[R_id,Vector2(m1,m2),Vector2(x0,y0),Vector2(...),],[R_id,Vector2(m1,m3),Vector2(x0,y0),Vector2(...),]]
func generate_move(b : Board) -> int:
	var board = b.gridList
	var E  = evaluate(board)
	var W : Array = getTargets(E,targetTime)
	#var C : Array = setTriggers(E)
	#for i in range(0,targetTime):
	#LOG_CLAUSE_CHAIN.append(GSystem.getClause(W,i,targetTime))
	update_grids(board)
	
	for dpu: DynamicalProcessingUnit in DPU_list:
		#dpu.update_layers()
		computeLayers(dpu.get_points())
		var points = 0
		var layer0Sum = 0
		var lowRelevance = true

		var isFull = true
		for p in dpu.get_points():
			if p.piece == 0:
				isFull = false
		if isFull:
			dpu.setLocalW(0)
			continue

		for p in dpu.get_points():
			layer0Sum += p.score[0]
			
			if GSystem.pattern(p,1, "fp.pf", 0, dpu.get_points()):
				dpu.setLocalW(2)
			if GSystem.pattern(p,1,"np.pn", 1, dpu.get_points()):
				dpu.setLocalW(1.6)
			if GSystem.pattern(p,-1, "npm.nmp.pnm.mpn", -1, dpu.get_points()):
				dpu.setLocalW(4)
			if GSystem.pattern(p,1,"pA",1,dpu.get_points()):
				dpu.setLocalW(-1.44)
				
			if p.piece != Point.EMPTY:
				points += 1
			if p.piece == Point.TOWER_OPPONENT:
				dpu.setLocalW(4)
			if p.piece == Point.BUBBLE_OPPONENT:
				dpu.setLocalW(5)
			if p.piece != Point.BUBBLE_OWN || p.piece != Point.EMPTY:
				lowRelevance = false
			
		if lowRelevance:
			dpu.setLocalW(-5.5)
		dpu.setLocalW(points / 2.0)
		dpu.setLocalW(-layer0Sum)
		layer0Sum = 0
		points = 0

	#MemoryUnit.triggers()
	#triggers from C are processed, settings flags, reordering DPU relevances for later phases

	var n = 0
	var moveIndex
	
	print("dpu 1 points")
	for p in DPU_list[1].get_points():
		print("point at",p.x,",",p.y," = ",p.score)
		print("testing pattern np.pn")
		GSystem.pattern(p,1,"np.pn", 1, DPU_list[1].get_points())
	
	

		
			

		
	
	var wTime = 10
	var tTime = 1
	DPU_list.sort_custom(sortRce)

	while(n < N_ROUNDS):
		var d = 2*abs(E[0][2])+1
		for h in range(0,2):
			var dpu : DynamicalProcessingUnit = DPU_list[h]
			var R = R_waypoints[0]
			var z_min = FSystem.computeError(dpu,R[0],tTime) #heptagon local search phase, 'backward inference' <-
			var p = Vector2(dpu.get_points()[R[0].x % 9].score[R[0].x / 9],dpu.get_points()[R[0].y % 9].score[R[0].y / 9])
			var TR_LIST = FSystem.generatePath(dpu,R[0],z_min[0],z_min[1],wTime,p) #find out transition chain, 'forward inference' ->
			TR_LIST.push_front(R[0][3])
			transitions.append(TR_LIST)
			Console.instance.write("Sera",str(TR_LIST[0]))
			print("added transition "+str(TR_LIST.back())+" using (m0,m1):"+str(TR_LIST[1]))
		n += 1
	
	var bestIndex = 0
	R_waypoints.sort_custom(computeLD)
	var bestVectors = []
	
	for i in range(0,R_waypoints.size()):
		var R_id = R_waypoints[i][1][3]
		for tr in transitions:
			if tr[0] == R_id:
				bestVectors.append([tr[0],tr[1],tr[2]])
				#print("m1=",tr[1].x," m2=",tr[1].y)
				
	var value = -1
	
	for j in range(0,bestVectors.size()):
		var bestDPU = DPU_list[floor(bestVectors[j][0]/(10**4))]
		var y = floor(bestVectors[j][1].x / 9)
		print("current dpu: ",bestDPU.id)
		#minimize vector (x0,y0) of {m1,m2} distance to N[y][m1][m2] + Rell_c(m1,change,dpu)
		var temp = GSystem.inferMove(y,bestVectors[j][1].x,bestVectors[j][1].y,bestVectors[j][2].x,bestVectors[j][2].y,bestDPU)
		assert(temp.size()!=0)
		var sq
		for k in range(0,temp.size()):
			print(temp[k])
			sq = temp[k]
			if sq[2] > value:
				value = sq[2]
				print("current best: ",sq[0]," ",sq[1])
				moveIndex = (sq[1] + bestDPU.offsetY - 1)*12 + sq[0] + bestDPU.offsetX - 1 
				
	prints("best move: ",moveIndex, getIndex(moveIndex))

	
	return moveIndex
	

func setPoints(layer,points,p,str,val):
	pass


func computeLayers(g):
	for p in g:
		var layer
		if GSystem.pattern(p,1, "fp.pf", 0, g): #'1' at p, 0 at fp && pf
			p.score[1] += 2.77
		elif GSystem.pattern(p,0, "pn.np", 1,g):
			p.score[1] += 5.7
		elif GSystem.pattern(p,-4, "pm", -1, g):
			setPoints(1,g,p,"mp",-2.0)
			
		if GSystem.pattern(p,1,"np.pn", 1, g):
			p.score[1] += 1.2
			setPoints(1,g,p,"np.pn",1.0)
			setPoints(1,g,p,"qp.pq.pe.ep",0.5)
		if GSystem.pattern(p,-1, "pD", -1, g) && GSystem.pattern(p,-1, "pA", 0, g):
			setPoints(layer,g,p,"pD",-9)
			setPoints(layer,g,p,"pA",3)
		if GSystem.pattern(p,1,"pA",1,g):
			setPoints(1,g,p,"pA",-1.44)

#ins = [metric,compValue,targetMetric,add]
#ins_2454 = [6,0,21,2.8]
#func parseIns(g):
	#for ic in ins_list:
		#if g[ic[0] / 9].score[ic[0] / 7] < ic[1]:
			#g[ic[2] / 9].score[ic[2] / 7] += ic[3]

func getStructures():
	var C = []
	C.append([0,1,0,-1,0,2.5,0,-2.5,1,1.5,-1,-1.5,2.5,-5,-2.5,5])
	
	


func getIndex(m):
	var s = "ABCDEFGHIJKL"
	return s[m%12]+str(m/12 + 1)

#generate rectangular subset R of metricplane Z (g_ij(y) is x-axis m_p is y-axis)
#this subset serves as a preliminary target to be reached by Transitions
func getTargets(eval,t):
	var temp = []
	for i in range(0, eval.size()):
		#TODO actual target generation, this is placeholder for first testing of the engine
		if( eval[i][2] < 0):
			temp.append(eval[i][1] + t + randi_range(1,10))#set the target: heuristic to be higher than opponent after t turns
		else:
			temp.append(eval[i][0] + randi_range(1,6)) #set target: heuristic grows 
	return temp

#convert instruction ins onto logical clause targets
func convertINS(ins):
	if ins.id == "HOLD_POS":
		var dpus = ins.dpus
		
	
#sort R waypoint manifolds using vector sampling(waypoint value) and current distance to waypoint(waypoint feasibility)
func computeLD(a,b) -> bool:
	var dpu = DPU_list[a[1][0]]
	var clause_dist1 = GSystem.sampleVec(a[1][1],1,a[0].x,a[0].y,a[0].z,a[0].w,Parameters.SAMPLE_COUNT,dpu)
	var clause_dist2 = GSystem.sampleVec(b[1][1],1,b[0].x,b[0].y,b[0].z,b[0].w,Parameters.SAMPLE_COUNT,dpu)
	var a_id = a[1][0]*10**4 + a[1][1]*10**2 + a[1][2]
	var b_id = b[1][0]*10**4 + b[1][1]*10**2 + b[1][2]
	var L1 = []
	var L2 = []
	
	for tr in transitions:
		if tr[0] == a_id:
			L1.append(tr.back())
		elif tr[0] == b_id:
			L2.append(tr.back())
	
	var trMin_a = 10000
	var trMin_b = 10000
	var points_a = FSystem.getArea(a[0].z,a[0].w)
	var points_b = FSystem.getArea(b[0].z,b[0].w)
	for t in L1:
		if FSystem.distToTarget(t.x,t.y,points_a) < trMin_a:
			trMin_a = FSystem.distToTarget(t.x,t.y,points_a)
	for t in L2:
		if FSystem.distToTarget(t.x,t.y,points_b) < trMin_b:
			trMin_b = FSystem.distToTarget(t.x,t.y,points_b)
			
	if 1.0/(clause_dist1*trMin_a) < 1.0/(clause_dist2*trMin_b):
		return true
	return false

func sortRce(a,b):
	if a.computeRelevance() > b.computeRelevance():
		return true
	return false

# evaluate heuristics H at current position pos0
# return array containing evaluations: [[e0,e0_t,coeff*(e0 - e0_t)], [e0,e0_t,coeff*(e0 - e0_t)], [e0,e0_t,coeff*(e0 - e0_t)]]
func evaluate(board):
	var W_COEFF = [1,2]
	var T = []
	var H_own = 0
	var H_opponent = 0
	
	for i in range(1,3):
		H_own = compute_heuristic(i,playerType,board)
		H_opponent = compute_heuristic(i,opponentType,board)
		T.append([H_own,H_opponent,W_COEFF[i-1]*(H_own - H_opponent)])
	print(T)
	return T
	
#helper function calling all necessary routines relating to move generation
func proceduralMove():
	#TODO fetch data from MEMUNIT
	result = generate_move(game_board)
	#TODO store recently computed N,N0 values for future
	

func init(board):
	init_dpu()
	Parameters.SEED = randi()
	if playerType == 3:
		opponentType = 1
	elif playerType == 1:
		opponentType = 3
	#FSystem.randomize_tables(Parameters.SEED)
	#testing
	#read SP polynomials, C constraints and read N,N0 matrix values
	FSystem.initialize()
	GSystem.populate()
	#TODO implement non-debug mode, where synthetic constraints, relations are created
	#TODO implement training mode
	#TODO read N,N0 from file
	
	for i in range(0,9):
		var x = randi_range(3,6)
		var y = randi_range(3,6)
		DPU_list[x*10 + y].setLocalW(10+randf_range(-1,1))
	
	for k in range(0,100):
		var dpu : DynamicalProcessingUnit = DPU_list[k]

		#print("relevance: ",dpu.computeRelevance())
		for i in range(0,1):
			for j in range(0,9): 
				var R = FSystem.getWaypointTarget(i,10) #create waypoint [m1,m2,nw_point,se_point] and append
				R.append([dpu.id,i,j,dpu.id*10**4+i*10**2+j])
				R_waypoints.append(R)
	

func makeMove(observation:Board):
	game_board = observation
	thread = Thread.new()
	thread.start(proceduralMove)
	
	while thread.is_alive():
		if observation == null || observation.get_tree() == null:
			break
		
		await observation.get_tree().process_frame

	thread.wait_to_finish()
	game_board.gridList[result].setTileType(playerType)
	#var console :TextEdit = observation.get_tree().root.get_node("root/Sidebar/TabContainer/Console/TextEdit2")
	#console.insert_line_at(0,"engine started")
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

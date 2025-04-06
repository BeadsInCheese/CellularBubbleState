extends Node
class_name DynamicalProcessingUnit

var INS:Instruction
var param:Parameters
var color : int
var currentTurn = 0

var offsetX
var offsetY
var id

var R : Array[Point] = []
var Q : Array[float]#coefficients for Rel(h_u,R_ij(y)) Q[k+9*j+9*7*w]


func init():
	for w in range(0,Parameters.HEUR_NO):
		for j in range(0,9):
			for k in range(0,7):
				Q.append(1)
	for i in range(0,9):
		var p : Point = Point.new()
		p.y = floor(i/3) 
		p.x = i % 3
		p.piece = 0
		p.score = [0,0,0,0,0,0,0]
		p.dpu = self
		R.append(p)
	for p in R:
		p.add_adjacents(p.x,p.y)

func get_points():
	return R

func get_N0(grid):
	var sum = 0
	for r : Point in grid:
		sum = sum+1
	return sum

func update(x,y,piece):
	update_point(x,y,piece)
	currentTurn += 1
	

#color player1 = 1, color player2 = 3
func update_layers():
	
	
	var G : Region = Region.new()
	G.add_data(R)
	#diag-capture
	#G.process_str("chk2_diag2_set&dinv-2,2_rR")
	#G.process(["check",2],["has_diag",2],["set","diag_invert",-2,2],["refresh",R])
	G.check(G,Point.BUBBLE_OWN)
	G.has_diag(Point.BUBBLE_OWN)
	G.set_data_cond(G.diag_invert(),Point.BUBBLE_OPPONENT,Point.BUBBLE_OWN)
	G.refresh_from(R)
	#bubble shifting rule
	#G.process_str("chk2_adj2_adj1_set&ACC@cdiag0,2_set&int&ACC@cdiag&adj2&2,0_rR")
	G = G.check(G,Point.BUBBLE_OWN)
	G = G.has_adj(Point.BUBBLE_OWN)
	G = G.has_adj(Point.TOWER_OWN)
	G.set_data_cond(G.ACC.corner_diag(),Point.EMPTY,Point.BUBBLE_OWN)
	G.set_data_cond(G.intersect(G.ACC.corner_diag().has_adj(Point.BUBBLE_OWN)),Point.BUBBLE_OWN,Point.EMPTY)
	G.refresh_from(R)
	#3-in-a-row addition rule
	G = G.check(G,Point.BUBBLE_OWN)
	G = G.has_adj(Point.BUBBLE_OWN)
	G.check(G.next(G.LAST),Point.BUBBLE_OWN)
	G.set_data_cond(G.LAST.has_adj(Point.EMPTY),Point.EMPTY,Point.BUBBLE_OWN)
	G.refresh_from(R)
	#tower-growing rule
	G.check(G,Point.TOWER_OWN)
	G = G.has_adj(Point.BUBBLE_OWN)
	G.set_data_cond(G.next(G.LAST),Point.EMPTY,Point.BUBBLE_OWN)
	G.refresh_from(R)
	#bubble creation rule
	G = G.check(G,Point.TOWER_OWN)
	G.check(G.next(G),Point.TOWER_OWN)
	G.set_data_cond(G.LAST,Point.EMPTY,Point.BUBBLE_OWN)
	G.refresh_from(R)
	#diagonal rule
	G = G.check(G,Point.TOWER_OWN)
	G.has_diag(Point.TOWER_OWN)
	G = G.add(G.check(G.ACC.diag_invert(),Point.BUBBLE_OWN))
	G.set_data_cond(G.corner_diag(),Point.EMPTY,Point.BUBBLE_OWN)
	
	for point : Point in R:
		#Layer 0 - standard scores(1 if own piece, -1 if enemy piece, 0 for empty)
		#Rule0(Diag-capture)
		
		
		#if(point.piece != 0):
			#add(point.x,point.y,1 if point.color == color else -1,0)
		#Layer 1 - default scores
		#1.4=own bubble,
		#1.0=own tower
		#-2.8=opponent bubble
		#-0.8=opponent tower
		if(point.piece != 0):
			if(point.piece == 1 && color == 1) || (point.piece == 3 && color == 3):
				add(point.x,point.y,1,1)
			if(point.piece == 3 && color == 1) || (point.piece == 1 && color == 3):
				add(point.x,point.y,-0.8,1)
			if(point.piece == 2 && color == 1) || (point.piece == 4 && color == 3):
				add(point.x,point.y,1.4,1)
			if(point.piece == 4 && color == 1) || (point.piece == 2 && color == 3):
				add(point.x,point.y,-2.8,1)
		#Layer2 - rule-dependent scores
		
		if(point.piece == Point.TOWER_OWN):
			for p in point.adj:
				if(p.piece == Point.BUBBLE_OWN):
					pass


func update_point(posX, posY, piece):
	var B = [[0,1,2],[3,4,5],[6,7,8]]
	if(piece == 1 && color == 1) || (piece == 3 && color == 3):
		R[B[posX+1][posY+1]].piece = Point.TOWER_OWN
	elif(piece == 1 && color == 3) || (piece == 1 && color == 3):
		R[B[posX+1][posY+1]].piece = Point.TOWER_OPPONENT
	elif(piece == 2 && color == 1) || (piece == 4 && color == 3):
		R[B[posX+1][posY+1]].piece = Point.BUBBLE_OWN
	elif(piece == 2 && color == 3) || (piece == 4 && color == 1):
		R[B[posX+1][posY+1]].piece = Point.BUBBLE_OPPONENT
	elif(piece == 0):
		R[B[posX+1][posY+1]].piece = Point.EMPTY


func inference_generic(p_coord_x, p_coord_y, layer_index, diff, w_index, old_data : Array[Point]) -> int:
	#TODO compute z_0 by Q values
	var z = old_data[0].score[layer_index]*randf()
	var t = 3
	print("z = ",z)
	print("starting inference:", "w_index=",w_index,"G_",p_coord_x,p_coord_y,"(",layer_index,")","for t = ",t)
	
	
	var j = randi() % len(old_data)
	var p : Point = old_data[j]
	var turn = (currentTurn + t) % 6
	var tr_chain = process(p.score[layer_index],layer_index,len(old_data) - j + t,turn,old_data)
	
	return 0

func process(metricTarget,layer,span,turn,data):
	var tries = 0
	var gamma = []
	var g
	var ins_list
	var final_ins_list
	var t = 10

	var data_o = []

	while(tries < param.MAX_TRIES):
		for h in range(0,63):
			var y = h/9 #layer
			var k = h%9 #index
			var i = k/3
			var j = k%3
			var T = FSystem.convert(Q[h])
			data_o = preprocess(data,y,k,i,j)
			var z = T[0] + T[1]*t
			#Forward Inference START
			#STEP 0. compute interval X_t_i
			var X_t = 2.55 * (max(data_o)-min(data_o)) / t + 1.44
			#STEP 1. 
			
		
		tries = tries + 1

	
	return final_ins_list
#
#func process(target, metricTarget):
	#var tries = 0
	#var gamma = []
	#var g
	#while(get_N0(get_points()) < target && tries < param.MAX_TRIES):
		#var ins_list = INS.getList(R) #[instr#1_move1,instr#1_move2,...]
		#var E = R
		#g = 0
		#for i in range(len(ins_list)):
			#var original = E
			#E = play(E,ins_list[i])
			#update_layers()
			#var metric = abs(metricTarget)
			#g += abs(evaluate(metric,E,original)) - param.metricCoeff*sign(metricTarget)
		#gamma.append(g)
		#tries = tries + 1
		#
	#var min = 500
	#for i in range(len(gamma)):
		#if(gamma[i] < min):
			#min = i
			#
	#print(min)
	

func preprocess(data : Array[Point],layer,index,i,j):
	pass

#gamma_ij
#-5 -> heuristic: 5, change: negative
func evaluate(metric : int, E : Array[Point], O : Array[Point]) -> int:
	var t = 0
	for i in range(9):
		t += E[i].score[metric] - O[i].score[metric]
			
	return t

func play(E : Array[Point],ins,layer) -> Array[Point]:
	var x = ins.x
	var y = ins.y
	var value_change = ins.value_change
	E[x + 3*y].score[layer] += value_change
	return E

func add(posX, posY, score, layer):
	R[posX-1 + 3*ceil((posY-1)/3)].score[layer] += score


func sub(posX, posY, score, layer):
	add(posX, posY, -score, layer)
	

func compute_translate_N():
	pass

#################################





#################################



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

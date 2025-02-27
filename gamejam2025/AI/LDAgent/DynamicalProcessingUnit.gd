extends Node
class_name DynamicalProcessingUnit

var INS:Instruction
var param:Parameters
var color : int

var offsetX
var offsetY
var id

var R : Array[Point] = []
var Q : Array[float]#coefficients for Rel(h_u,R_ij(y)) Q[k+9*j+9*7*w]
enum Piece {EMPTY,TOWER_OWN,BUBBLE_OWN,TOWER_OPPONENT,BUBBLE_OPPONENT,TOWER,BUBBLE}


func init():
	for w in range(0,Parameters.HEUR_NO):
		for j in range(0,9):
			for k in range(0,7):
				Q.append(1)
	for i in range(0,9):
		var p : Point = Point.new()
		p.x = floor(i/3) + 1
		p.y = i % 3 + 1
		p.piece = 0
		p.score = [0,0,0,0,0,0,0]
		R.append(p)
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
	

#color player1 = 1, color player2 = 3
func update_layers():
	for point : Point in R:
		#Layer 0 - standard scores(1 if own piece, -1 if enemy piece, 0 for empty)
		#Rule0(Diag-capture)
		if(point.piece == Piece.BUBBLE_OWN):
			for p in point.adj_diag:
				if(p.piece == Piece.BUBBLE_OWN):
					pass
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
		
		if(point.piece == Piece.TOWER_OWN):
			for p in point.adj:
				if(p.piece == Piece.BUBBLE_OWN):
					pass


func update_point(posX, posY, piece):
	var B = [[0,1,2],[3,4,5],[6,7,8]]
	if(piece == 1 && color == 1) || (piece == 3 && color == 3):
		R[B[posX+1][posY+1]].piece = Piece.TOWER_OWN
	elif(piece == 1 && color == 3) || (piece == 1 && color == 3):
		R[B[posX+1][posY+1]].piece = Piece.TOWER_OPPONENT
	elif(piece == 2 && color == 1) || (piece == 4 && color == 3):
		R[B[posX+1][posY+1]].piece = Piece.BUBBLE_OWN
	elif(piece == 2 && color == 3) || (piece == 4 && color == 1):
		R[B[posX+1][posY+1]].piece = Piece.BUBBLE_OPPONENT
	elif(piece == 0):
		R[B[posX+1][posY+1]].piece = Piece.EMPTY


func inference_generic(p_coord_x, p_coord_y, layer_index, diff, w_index, old_data : Array[Point]) -> int:
	#TODO compute z_0 by Q values
	var z = max(old_data)*randf()
	var t = randi_range(5,10)
	print("z = ",z)
	print("starting inference:", "w_index=",w_index,"G_",p_coord_x,p_coord_y,"(",layer_index,")")
	
	var j = randi() % len(old_data)
	var p : Point = old_data[j]
	var tr_chain = process(p.score[layer_index],layer_index,len(old_data) - j + t)
	
	return 0

func process(metricTarget,layer,span):
	var tries = 0
	var gamma = []
	var g
	var ins_list
	var final_ins_list
	#TODO (h_i,h_j) functions
	while(tries < param.MAX_TRIES):
		ins_list = INS.get_list(R,span) #[instr#1_move1,instr#1_move2,...]
		var E = R
		g = 0
		for i in range(len(ins_list)):
			var original = E
			E = play(E,ins_list[i],layer)
			#update_layers()
			#var metric = abs(metricTarget)
			g += abs(evaluate(layer,E,original)) - param.metricCoeff*sign(metricTarget)
		gamma.append(g)
		tries = tries + 1
		final_ins_list = ins_list
		var min = 500
		for i in range(len(gamma)):
			if(gamma[i] < min):
				min = i
			
	print(min)
	
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

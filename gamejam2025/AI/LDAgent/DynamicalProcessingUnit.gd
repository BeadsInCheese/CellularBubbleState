extends Node
class_name DynamicalProcessingUnit

var INS:Instruction
var color : int
var currentTurn

var offsetX
var offsetY
var id
var channelIndex : int
var gates = []

var R : Array[Point] = []
var Q : Array[float]#coefficients for Rel(h_u,R_ij(y)) Q[k+9*j+9*7*w]
var relevance = 1.0
var W = 1.0
var flags = []
var targetTime
var LATTICE_SIZE = 4

func init(c):
	color = c
	for w in range(0,2):
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
	#print("initialized DPU ",id," at ",offsetX,",",offsetY)

#get neighboring DPU:s which also has the square (i,j), i,j in {0,1,2}
func get_neighboring(i,j) -> Array:
	var ids = []
	#TODO finish
	for m in range(i,3):
		for n in range(j,3):
			ids.append(id+12*m)
			ids.append(id+12*m+n)
			ids.append(id+12*n)
			ids.append(id+12*n+m)
			
	#edge cases remove
	if (id % 12 == 0 && j == 0):
		ids.append(id+1)
	if (id % 12 == 11 && j == 2):
		ids.append(id-1)
	if (id/12 == 0 && i == 0):
		ids.append(id+12)
	if (id/12 == 11 && i == 2):
		ids.append(id-12)
		
	return ids

func get_points():
	return R

func get_N0():
	var sum = 0
	for r : Point in R:
		if r.piece != Point.EMPTY:
			sum = sum+1
	return sum


func computeRelevance():
	return W*relevance

	
func setLocalW(x):
	#print("adding ",x," to ",W)
	W += x
	
func update_layers():
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
	if(piece == 1 && color == 1) || (piece == 3 && color == 3):
		R[3*(posX) + posY].piece = Point.TOWER_OWN
	elif(piece == 1 && color == 3) || (piece == 3 && color == 1):
		R[3*(posX) + posY].piece = Point.TOWER_OPPONENT
	elif(piece == 2 && color == 1) || (piece == 4 && color == 3):
		R[3*(posX) + posY].piece = Point.BUBBLE_OWN
	elif(piece == 2 && color == 3) || (piece == 4 && color == 1):
		R[3*(posX) + posY].piece = Point.BUBBLE_OPPONENT
	elif(piece == 0):
		R[3*(posX) + posY].piece = Point.EMPTY

func inference_generic_backward(x,y,R,startVector,targetVector,tTime,endPointY):
	targetTime = tTime
	#print("starting backward inference: G_",((R[0]%9)%3),((R[1]%9)/3),"(",R[0]/9,")","for v0 = ",startVector," v1 = ",targetVector)
	var dy = process_backward(startVector,targetVector,tTime,R)
	return dy


func inference_generic(x,y,R, startVector, targetVector, t0) -> int:
	#print("starting inference: G_",((R[0]%9)%3),((R[1]%9)/3),"(",R[0]/9,") at (",x,",",y,") for v0 = ",startVector," v1 = ",targetVector)
	var dy = process_forward(startVector,targetVector,t0,R)
	return dy

# R = [y1*i*j,y2*m*n,ulpx,p2,dpu_id,w_k,lattice_j]
# TR = [(y1*i*j,y2*m*n),(x1,y1),(x2,y2),...,(xn,yn)]

func process_forward(vector0,vector,t,R) -> float:
	t /= 2
	var SPfunction = FSystem.interpolateVector(vector0,vector)
	var tValue = FSystem.evaluateAtMidpoint(SPfunction[0],SPfunction[1])
	var dyVector = MathLib.getDVector(SPfunction,t)
	var newVector = Vector2(1,GSystem.dslLearning(self,R,Vector2(1,dyVector.y - tValue)))
	MemoryUnit.storeDiff(R,dyVector,newVector)
	if(t < 1):
		return newVector.y
	else:
		return process_forward(vector0,newVector,t,R)

func process_backward(vector0,vector,t,R) -> float:
	t = targetTime - t/2
	var SPfunction = FSystem.interpolateVector(vector0,vector)
	var valueAtTarget = FSystem.evaluateAtT(SPfunction[1], targetTime)
	var tValue = FSystem.evaluateAtMidpoint(SPfunction[0],SPfunction[1])
	var dyVector = MathLib.getDVector(FSystem.interpolatePoint(Vector2(t,tValue),Vector2(targetTime,valueAtTarget)),t)
	var newVector = Vector2(1,GSystem.dslLearning(self,R,Vector2(1,dyVector.y - tValue)))
	MemoryUnit.storeDiff(R,dyVector,newVector)
	if(is_equal_approx(t,targetTime)):
		return newVector.y
	else:
		return process_backward(vector0,newVector,t,R)



func add(posX, posY, score, layer):
	R[posX-1 + 3*ceil((posY-1)/3)].score[layer] += score


func sub(posX, posY, score, layer):
	add(posX, posY, -score, layer)
	


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

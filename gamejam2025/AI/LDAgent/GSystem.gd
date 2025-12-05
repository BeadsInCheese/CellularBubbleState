extends Node

class_name GSystem

'''class for G-grid decomposition analysis, G-gradings of all 7 layers, and all Grid value reasonings

contains also Principles C_0 & C_1
'''


#gates list
#g = 0, always_true
#g_i format : [(t,y,i,j),...]
static var gates : Array[Vector4]

'''var N_0 = [[1,4,2,5,6,2,-1,3,28],
[-1,1,4,7,3,5,1,4,2],
[-3,2,1,4,7,3.4,3,6,6.1],
[3,4,2,1,4,7,4,2,5],
[7,7,86.5,3,1,7,4,0,11],
[1,3,1,3,1,1,7,8,9],
[2,2,13,3,4.1,5,1,6,7],
[1,4,5,6,3,3,6,1,8],
[1,3,5,7,5,4,3,-6,1]]

var N_1
var N_2
var N_3
var N_4
var N_5
var N_6
var N0_0
var N0_1
var N0_2
var N0_3
var N0_4
var N0_5
var N0_6'''
'''
i = 1, j = 1
metric {y2,2,0}
target 5
eval 1

Rell_y1y2_{2,0}{1,1} = -1
Rell_y3y2_{2,0}{1,1} = 0.1
Rell_y4y2_{2,0}{1,1} = 0.0
Rell_y5y2_{2,0}{1,1} = 1.2
Rell_y6y2_{2,0}{1,1} = 1

J1 = 4
d = 0

for i in range(0,7):
	d += rell(y1,y2,i,j,m,n)
	Rell_y1y2_{2,0}{1,1}
	
sum: 1.3

return 1.0 - 1.3/target = 0.74

'''
static var relvector = []
static var collection1 = []
static var collection2 = []



static func getRelVector(dpu,i,j):
	for y in range(0,7):
		relvector.append(dpu.get_points()[3*i+j].score[y])

static func rell(y1,y2,i,j,m,n):
	var temp1_1 = MathLib.mult(collection1[y1],collection2[y1])
	var temp1_2 = MathLib.mult(temp1_1,relvector)
	var temp2_1 = MathLib.mult(collection1[y2],collection2[y2])
	var temp2_2 = MathLib.mult(temp2_1,relvector)
	return temp2_2 - temp1_2

static func populate():
	var temp : Array[Array]
	var column : Array
	for i in range(0,7):
		for j in range(0,9):
			for k in range(0,9):
				if j == k:
					column.append(1)
				else:
					column.append(randf_range(-5.0,5.0))
			temp.append(column)
		collection1.append(temp)
		
		temp.clear()
		column.clear()
		for j in range(0,7):
			for k in range(0,9):
				column.append(randf_range(-5.0,5.0))
			temp.append(column)
		collection2.append(temp)

#rell_y_ij
#check if y is within any Gates and apply F0
static func getRelation(value,R):
	for h in range(0,gates.size()):
		if(gates[h][1] > value):
			return 

	
#how hard is it to get metric -> target by playing at (i,j)?
static func distance(dpu,i,j, metric,target):
	var curr = dpu.get_points()[metric / 9].score[metric % 7]
	var J1 = target - curr
	

#return a 3D-matrix(as a vector) of approximate change of w, when piece of type t(-is opponent), is played at G_y_ij with gates g
#gates g is an index to GateList, g=0 denotes ALWAYS_TRUE Gate
static func wInft(w,y,i,j,t,g:int):
	var R : Array
	#[w_0-section of [y0-section of [ij-section of 9 cells]]] = 63 cells
	#wInfc(0,0,0,0,1,0) = 1, i.e. when you play (1,1) at (0,0) top-left square, w0 (amount of points) always increases by 1
	#wInfc(0,0,0,0,2,0) = 5/7 = 1/1.4 as "playing" (2,1) has multiplier of 1.4 on layer 0, but still increases w0 by only 1
	#wInfc(4,0,1,1,1,3) = 4.2, as g=3 evaluates to [(1,1,0,1),(1,1,0,2)] and playing (1,1) gives a 3-length wall(set as 4.2)
	if w == 0 && y == 0 && t == 1:
		return 1
	elif w == 0 && y == 0 && t == 2:
		return 5.0/7.0
	else:
		return randf_range(-2.5,2.5)
	

static func convertInG(dpu,y1,i,j,m,n):
	pass

static func convertLayers(dpu,y1,y2,m,n):
	pass

static func getClause(W : Array,t,end):
	var clause = []
	for i in range(0,W.size()):
		clause.append(W[i]**(1-2/((W[i]*t/end)**3)))
	return clause

static func parse(clause):
	return -0.1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gates.append(Vector4())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

extends Node
class_name DynamicalProcessingUnit

var INS:Instruction
var param:Parameters
var color : int

var offsetX
var offsetY
var id

var R : Array[Point] = []

func get_points():
	return R

func get_N0(grid):
	var sum = 0
	for r : Point in grid:
		sum = sum+1
	return sum

func update(x,y,piece,R):
	update_point(x,y,piece)
	update_layers(R)

func update_layers(R):
	for point : Point in R:
		#Layer 0 - standard scores(sum of all own pieces on the board)
		if(point.piece != 0):
			add(point.x,point.y,1 if point.color == color else 0,0)
		

func update_point(posX, posY, piece):
	R[posX-1 + 3*ceil((posY-1)/3)].piece = piece


func process(target, metricTarget):
	var tries = 0
	var gamma = []
	var g
	while(get_N0(get_points()) < target && tries < param.MAX_TRIES):
		var ins_list = INS.getList(R) #[instr#1_move1,instr#1_move2,...]
		var E = R
		g = 0
		for i in range(len(ins_list)):
			var original = E
			E = play(E,ins_list[i])
			update_layers(E)
			var metric = abs(metricTarget)
			g += abs(evaluate(metric,E,original)) - param.metricCoeff*sign(metricTarget)
		gamma.append(g)
		tries = tries + 1
		
	var min = 500
	for i in range(len(gamma)):
		if(gamma[i] < min):
			min = i
			
	print(min)
	

#gamma_ij
#-5 -> heuristic: 5, change: negative
func evaluate(metric : int, E : Array[Point], O : Array[Point]) -> int:
	var t = 0
	for i in range(9):
		t += E[i].score[metric] - O[i].score[metric]
			
	return t

func play(E : Array[Point],p : int) -> Array[Point]:
	E[p].piece = 1
	return E

func add(posX, posY, score, layer):
	R[posX-1 + 3*ceil((posY-1)/3)].score[layer] += score


func sub(posX, posY, score, layer):
	add(posX, posY, -score, layer)
	

func compute_translate_N():
	pass

#################################





#################################

func _init():
	for i in range(0,9):
		var p : Point = Point.new()
		p.x = floor(i/3) + 1
		p.y = i % 3 + 1
		p.piece = 0
		R.append(p)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

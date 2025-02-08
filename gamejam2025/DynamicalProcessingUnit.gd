extends Node
class_name DynamicalProcessingUnit

var color : int

var offsetX
var offsetY
var id

var R : Array[Point] = []

func get_points():
	return R

func update(x,y,piece):
	update_point(x,y,piece)
	update_layers()

func update_layers():
	for point : Point in R:
		#Layer 0 - standard scores(sum of all own pieces on the board)
		if(point.piece != 0):
			add(point.x,point.y,1 if point.color == color else 0,0)
		

func update_point(posX, posY, piece):
	R[posX-1 + 3*ceil((posY-1)/3)].piece = piece

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

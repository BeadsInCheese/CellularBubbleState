extends Node
class_name Point

var x
var y
var dpu : DynamicalProcessingUnit
var adj : Array[Point]
var adj_diag : Array[Point]
var score : Array[float]
var piece : int
var color : int


func chk_wsen_o_own(x,y,color) -> Array[Point]:
	var G : Array[Point] = []
	for p : Point in dpu.get_points()[x][y].adj:
		if(p.piece == 2 and color or p.piece == 4 and not color):
			G.append(p)
	return G
	
func chk_wsen_t_own(x,y,color) -> Array[Point]:
	var G : Array[Point] = []
	for p : Point in dpu.get_points()[x][y].adj:
		if(p.piece == 1 and color or p.piece == 3 and not color):
			G.append(p)
	return G

func add_adjacent(posX,posY):
	if dpu.get_points()[posX][posY+1] != 0:
		adj.append(dpu.get_points()[posX][posY+1])
	if dpu.get_points()[posX+1][posY] != 0:
		adj.append(dpu.get_points()[posX+1][posY])
	if dpu.get_points()[posX][posY-1] != 0:
		adj.append(dpu.get_points()[posX][posY-1])
	if dpu.get_points()[posX-1][posY] != 0:
		adj.append(dpu.get_points()[posX-1][posY])


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

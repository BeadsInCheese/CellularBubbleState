extends Node
class_name Point

var x
var y
var region : Region
var dpu : DynamicalProcessingUnit
var adj : Array[Point]
var adj_diag : Array[Point]
var score : Array[float]
var piece
var color : int

enum Piece{EMPTY,TOWER_OWN,BUBBLE_OWN,TOWER_OPPONENT,BUBBLE_OPPONENT,TOWER,BUBBLE}

func chk_wsen_o_own(x,y,color) -> Array[Point]:
	var G : Array[Point] = []
	for p : Point in dpu.get_points()[x][y].adj:
		if(p.piece == Piece.BUBBLE_OWN):
			G.append(p)
	return G
	
func chk_wsen_t_own(x,y,color) -> Array[Point]:
	var G : Array[Point] = []
	for p : Point in dpu.get_points()[x][y].adj:
		if(p.piece == Piece.TOWER_OWN):
			G.append(p)
	return G

func add_adjacents(posX,posY):
	
	if posY < 2 && dpu.get_points() [posX][posY+1] != 0:
		adj.append(dpu.get_points()[posX][posY+1])
	if posX < 2 && dpu.get_points()[posX+1][posY] != 0:
		adj.append(dpu.get_points()[posX+1][posY])
	if posY > 0 && dpu.get_points()[posX][posY-1] != 0:
		adj.append(dpu.get_points()[posX][posY-1])
	if posX > 0 && dpu.get_points()[posX-1][posY] != 0:
		adj.append(dpu.get_points()[posX-1][posY])

func next(from : Point):
	return region.get_point(x-sign(from.x - x),y-sign(from.y - y))
	
func skip(amount, from):
	return region.get_point(x-(amount+1)*sign(from.x - x),y-(amount+1)*sign(from.y - y))
	
func adjacent(dir_wsen):
	if(dir_wsen == 1):
		return region.get_point(x,y-1)
	elif(dir_wsen == 2):
		return region.get_point(x+1,y)
	elif(dir_wsen == 3):
		return region.get_point(x,y+1)
	elif(dir_wsen == 4):
		return region.get_point(x-1,y)
	
func liner(slope,S: Region):
	var tempX = x
	var tempY = y
	for i in range(0,2):
		for j in range(0,2):
			tempX += 1
			tempY += slope
			if(tempX < 3 && tempX > -1 && tempY < 3 && tempY > -1):
				for p :Point in S.data:
					if p.x == tempX && p.y == tempY:
						return p

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

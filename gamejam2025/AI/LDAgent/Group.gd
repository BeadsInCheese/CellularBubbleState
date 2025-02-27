extends Node
class_name Region


var data = []
var G = [[0,0,0],[0,0,0],[0,0,0]]
enum Piece{EMPTY,TOWER_OWN,BUBBLE_OWN,TOWER_OPPONENT,BUBBLE_OPPONENT,TOWER,BUBBLE}

enum Regions{COMPLEMENT}

func initialize(r : Regions, L : Region) -> Region:
	var Z : Region = Region.new()
	if(r == Regions.COMPLEMENT):
		for x in range(1,3):
			for y in range(1,3):
				for p in L.data:
					if(p.x != x || p.y != y):
						Z.data.append(p)
	return Z


func check(L, pattern) -> Region:
	var Q : Region = Region.new()
	for p in L:
		if(p.piece == pattern):
			Q.data.append(p)
	return Q
	
func get_point(x,y):
	if(x < 0 || x > 2 || y < 0 || y > 2):
		printerr("point out of range!")
	for p in data:
		if(p.x == x && p.y == y):
			return p

func liner(start : Point,S : Region) -> Region:
	var R : Region = Region.new()
	
	return R
	
func skip_from_dir(p : Point) -> Region:
	var R : Region = Region.new()
	
	return R
	
func get_neighbors(p : Point, L : Region) -> Region:
	var Z : Region = Region.new()
	var O : Region = Region.new()
	O = O.initialize(Regions.COMPLEMENT, L)
	for d in data:
		Z.add(Z,liner(d,O))

	return Z

func diag_invert():
	var R : Region = Region.new()
	for d in data:
		for p in d.adj_diag:
			if(sign(p.y-d.y) == 1):
				if(sign(p.x-d.x) == 1):
					pass

func corner_diag():
	for d in data:
		for p : Point in d.adj_diag:
			if(p.piece != Piece.EMPTY):
				if(get_point(d.x,d.y + sign(p.y-d.y)).piece == Piece.EMPTY):
					return get_point(d.x + sign(p.x-d.x),d.y)
				elif(get_point(d.x + sign(p.x-d.x),d.y).piece == Piece.EMPTY):
					return get_point(d.x,d.y + sign(p.y-d.y))

# Add two Regions onto one
func add(G1 : Region,G2 : Region) -> Region:
	var R : Region = Region.new()
	for p in G1.data:
		R.data.append(p)
	for p in G2.data:
		for r in G1.data:
			if(p.id != r.id):
				R.data.append(p)
	return R

#Returns the common elements of two Regions
func intersect(G1 : Region,G2 : Region):
	var R : Region = Region.new()
	for p in G2.data:
		for r in G1.data:
			if(p.id == r.id):
				R.data.append(p)
	return R
	


###########################

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

extends Node
class_name Region


var data = []
var G = [[0,0,0],[0,0,0],[0,0,0]]

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
	
func n_check(L, pattern) -> Region:
	var Q : Region = Region.new()
	for p in L:
		if(p.piece != pattern):
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
	
func get_neighbors(L : Region) -> Region:
	var Z : Region = Region.new()
	var O : Region = Region.new()
	O = O.initialize(Regions.COMPLEMENT, L)
	for d in data:
		Z.add(Z,liner(d,O))

	return Z


func diag_invert():
	var R : Region = Region.new()
	for p in n_check(self,0).data:
		var diagonals = Region.new()
		diagonals.add_data(p.adj_diag)
		for d : Point in n_check(diagonals,0).data:
			R.data.append(d)
			R.data.append(p)
			R.data.append(R.corner_diag())
			R.data.append(R.corner_diag())
	R.data.pop_front()
	R.data.pop_front()
	return R


func corner_diag():
	for p in n_check(self,0).data:
		var diagonals = Region.new()
		diagonals.add_data(p.adj_diag)
		for d : Point in n_check(diagonals,0).data:
			if(get_point(d.x - sign(d.x-p.x),d.y).piece != Point.EMPTY):
				return get_point(d.x, d.y - sign(d.y-p.y))
			else:
				return get_point(d.x - sign(d.x-p.x),d.y)
					
					
func set_data_cond(L:Region,pattern,d):
	for p in check(L,pattern).data:
		p.piece = d
		p.score[0] = d
		
	return L.data
		

#Concatenate list onto existing data
func add_data(list : Array[Point]):
	data.append_array(list)
	
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

#Returns the common elements of this Region and G
func intersect(G : Region):
	var R : Region = Region.new()
	for p in data:
		for r in G.data:
			if(p.id == r.id):
				R.data.append(p)
	return R
	
func subtract(G : Region):
	var R : Region = Region.new()
	for p in data:
		for g in G.data:
			if(p.id != g.id):
				R.data.append(p)
	return R

###########################

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

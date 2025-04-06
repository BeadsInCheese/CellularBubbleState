extends Node
class_name Region


var data = []
var G = [[0,0,0],[0,0,0],[0,0,0]]
var n = 0
static var MATCH : Point
var ACC : Region = Region.new()
var LAST : Region = Region.new()
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

func process(a ):
	pass

func check(L, pattern) -> Region:
	for p in L:
		if(p.piece == pattern):
			data.append(p)
	ACC.add(self)
	return self
	
func n_check(L, pattern) -> Region:
	for p in L:
		if(p.piece != pattern):
			data.append(p)
	ACC.add(self)
	return self
	
func get_point(x,y):
	if(x < 0 || x > 2 || y < 0 || y > 2):
		printerr("point out of range!")
	for p in data:
		if(p.x == x && p.y == y):
			return p

func liner(start : Point,S : Region) -> Region:
	var R : Region = Region.new()
	
	ACC.add(R)
	return R
	
func next(from):
	var R : Region = Region.new()
	for p in data:
		for n in from.data:
			R.add_point(p.next(n))
			R.LAST.add_point(p)
	return R
	
func skip_from_dir(p : Point) -> Region:
	var R : Region = Region.new()
	
	ACC.add(R)
	return R
	
func get_neighbors(L : Region) -> Region:
	var Z : Region = Region.new()
	var O : Region = Region.new()
	O = O.initialize(Regions.COMPLEMENT, L)
	for d in data:
		Z.add(liner(d,O))

	ACC.add(Z)
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
	ACC.add(R)
	return R

func has_adj(piece):
	var R : Region = Region.new()
	for p : Point in data:
		for a in p.adj:
			if(a.piece == piece):
				LAST.add_point(p)
				R.data.append(a)
	ACC.add(R)
	return R

func has_diag(piece):
	var R : Region = Region.new()
	for p : Point in data:
		for a in p.adj_diag:
			if(a.piece == piece):
				LAST.add_point(p)
				R.data.append(a)
	ACC.add(R)
	return R

func corner_diag() -> Region:
	var R : Region = Region.new()
	for p in n_check(self,0).data:
		var diagonals = Region.new()
		diagonals.add_data(p.adj_diag)
		for d : Point in n_check(diagonals,0).data:
			if(get_point(d.x - sign(d.x-p.x),d.y).piece != Point.EMPTY):
				R.append(get_point(d.x, d.y - sign(d.y-p.y)))
			else:
				R.append(get_point(d.x - sign(d.x-p.x),d.y))
					
					
	#ACC.add(R)
	return R
					
func set_data_cond(L:Region,pattern,d):
	for p in check(L,pattern).data:
		p.piece = d
		p.score[0] = d
		
	return L.data
		

func flush_acc():
	ACC = Region.new()

func refresh_from(data):
	flush_acc()
	self.data.clear()
	self.data = data

#Concatenate list onto existing data
func add_data(list : Array[Point]):
	data.append_array(list)
	
func add_point(p : Point):
	data.append(p)
	
# Add two Regions onto one
func add(G1 : Region) -> Region:
	var R : Region = Region.new()
	for p in G1.data:
		R.data.append(p)
	for p in self.data:
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

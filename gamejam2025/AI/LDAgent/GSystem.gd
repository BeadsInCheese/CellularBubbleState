extends Node

class_name GSystem

'''class for G-grid decomposition analysis, G-gradings of all 7 layers, and all Grid value reasonings

contains also Principles C_0 & C_1
'''

static var relvector = []
static var collection1 = [] #9*9*7 matrix
static var collection2 = [] #9*7*7 matrix

static var C = []
static var seq = []
	
static var ge = []
static var e0 = []

static func loadData():
	var lines1 = []
	var lines2 = []
	
	var file = FileAccess.open("/EngineData-ldagent/train/dataN1", FileAccess.READ)
	while(file.get_position() < file.get_length()):
		var str = file.get_line()
		lines1.append(str)
	file.close()
	
	var file2 = FileAccess.open("/EngineData-ldagent/train/dataN0", FileAccess.READ)
	while(file2.get_position() < file.get_length()):
		var str = file.get_line()
		lines2.append(str)
	file2.close()
	
	#0 1 3 3 5 2 3
	var line = 0
	var column = 0
	for row in lines1:
		for j :String in row.split(" "):
			collection1[line / 81][column*9 + line] = j.to_float()
			column += 1
		line += 1
		
	line = 0
	column = 0
	for row in lines2:
		for j :String in row.split(" "):
			collection2[line / 63][column*9 + line] = j.to_float()
			column += 1
		line += 1
		
	print("N & N0 loaded from disk!")

static func getRelVector(dpu,i,j):
	for y in range(0,7):
		relvector.append(dpu.get_points()[3*i+j].score[y])

static func rell(y1,y2,i,j,m,n):
	var temp1_1 = MathLib.mult(collection1[y1],collection2[y1])
	var temp1_2 = MathLib.mult(temp1_1,relvector)
	var temp2_1 = MathLib.mult(collection1[y2],collection2[y2])
	var temp2_2 = MathLib.mult(temp2_1,relvector)
	var sum = 0
	for k in range(0,temp2_2.size()):
		sum += temp2_2[k] - temp1_2[k]
	return sum

static func populate():
	
	
	for i in range(0,7):
		var temp = []
		for j in range(0,9):
			for k in range(0,9):
				if j == k:
					temp.append(1)
				else:
					temp.append(randf_range(-5.0,5.0))
		collection1.append(temp)
		
		
	for i in range(0,7):
		var temp = []
		for j in range(0,7):
			for k in range(0,9):
				temp.append(randf_range(-5.0,5.0))
		collection2.append(temp)
	
	for i in range(0,7):
		var row = []
		for j in range(0,9):
			var col = []
			for k in range(0,9):
				col.append(0)
			row.append(col)
		e0.append(row)
		
	

#start Dynamic System Logic Learning phase, update N,N0 values and compute approximation of rell_y1y2_{i,j}{m,n}
static func dslLearning(dpu,R,dyDiffVector): 

	var result = 0
	#var flags = dpu.flags
	#var gates = dpu.gates
	#var channelIndex = dpu.channelIndex
	var y1 = R[0] / 9
	var i1 = (R[0] % 9) % 3
	var j1 = (R[0] % 9) / 3
	var i2 = (R[1] % 9) % 3
	var j2 = (R[1] % 9) / 3
	var randValue : float = 0
	var errors = []
	
	dyDiffVector = dyDiffVector.normalized()
	var l_sqr = dyDiffVector.x**2 + dyDiffVector.y**2
	
	for M in range(0,1):
		randValue = randf_range(-l_sqr + dyDiffVector.x,l_sqr + dyDiffVector.x)
		computeSeq(i2,j2,y1,randValue,dpu,i2,j2,y1,false)
		errors.append([randValue,abs(e0[y1][i2][j2])])
		
	var min = 10000
	for e in errors:
		if e[1] < min:
			min = e[1]
			result = e[0]
	
	var y = sqrt(1-result**2)
	
	return y / result



static func computeSeq(a,b,q,randValue,dpu,x1,x2,layer,stop):
	var g = dpu.get_points()
	var i = (a+1)%3
	var j = (b+1)%3
	var y = q
	while(!stop):
		while(!stop):
			setRelInG(q,a,b,i,j,g[3*i+j].score[q]/randValue)
			seq.append([i,j,q])
			var id = ((i*3+j)*7 + y)*100 + dpu.id
			FSystem.REL.get_or_add(id,-1.0)
			while(!stop):
				setRell(q,y,i,j,g[3*i+j].score[y]/randValue)
				seq.append([i,j,y])
				if(i == x1 && j == x2 && y == layer):
					e0[y][i][j] = collection2[y][9*q + 3*i+j] - randValue
					return true
				i = (i+1) % 3
				j = (j+1) % 3
				y = (y+1) % 7
				stop = computeSeq(i,j,y,randValue,dpu,x1,x2,layer,stop)
				
	return true

static func setRell(y1,y2,m,n,value):
	collection2[y2][9*y1 + 3*m+n] = value

static func setRelInG(y1,i,j,m,n,value):
	collection1[y1][9*(3*i+j) + 3*m+n] = value
	
#dm_1 * relg(m1,m2,y1) + rell(m2,y1,0)
#returns [i,j,confidence] where (i,j) is the point closest to 1.0 in layer 0 (the move layer)
static func inferMove(y,m1,m2,d_m1,d_m2,dpu):
	var R = []
	var t = 0
	m1 = fmod(m1,9)
	m2 = fmod(m2,9)
	var temp1
	var temp2
	
	for i2 in range(0,3):
		for j2 in range(0,3):
			prints("dpu:",dpu.id,"i2",i2,"j2",j2,"piece:",dpu.get_points()[3*i2+j2].piece)
			if dpu.get_points()[3*i2+j2].piece != 0:
				continue
			
			#rel(0,i2,j2,y,i2,j2) + rel(y,i2,j2,y, (m1 % 9) % 3, (m1 % 9) / 3)
			t += pow(collection2[0][9*y + 3*i2+j2] + collection1[y][9*(3*i2+j2) + m1] - d_m1,-4)
			t += pow(collection2[0][9*y + 3*i2+j2] + collection1[y][9*(3*i2+j2) + m2] - d_m2,-4)
			
			
			for cl in C:
				for constraint in cl:
					t += 1.0/((constraint[0] - dpu.get_points()[3*i2+j2].score[0])**4)
					t += 1.0/((constraint[1] - d_m1*collection2[y][m1])**4)

			R.append([i2,j2,t])
			t = 0

	
	return R


static func sampleVec(w, change_direction, m1, m2, pUL, pLR, N, dpu):
	getRelVector(dpu,(m1 % 9) % 3, (m1 % 9) / 3)
	var points = FSystem.getArea(pUL,pLR)
	var r = 1
	var avg = 0
	var B = []
	for i in range(0,N):
		var x = randf_range(0,99)
		var y = randf_range(0,99)
		for k in range(0,10):
			var dR = FSystem.computeTurnedVector(points,x,y).normalized()
			var v = Vector2(x + randf_range(-2.0,2.0),y + randf_range(-2.0,2.0)).normalized()
			var dotp = dR.x*v.x + dR.y*v.y
			var d1 = rell(m1/9,0,(m1 % 9) % 3,(m1 % 9)/3, (m1 % 9) % 3, (m1 % 9)/3)
			var d2 = rell(m2/9,0,(m2 % 9) % 3,(m2 % 9)/3, (m2 % 9) % 3, (m2 % 9)/3)
			B.append(dotp * abs(d1 - d2))

	var sum = 0.0
	for b in B:
		sum += b
		
	relvector.clear()
		
	return sum / B.size()

#return an approximate change of w, when piece of type t(-is opponent), is played at G_y_ij
static func wInft(w,y,i,j,g:int):
	var R : Array
	#[w_0-section of [y0-section of [ij-section of 9 cells]]] = 63 cells
	#wInfc(0,0,0,0,0) = 1, i.e. when you play 1 at (0,0) top-left square, w0 (amount of points) always increases by 1
	#wInfc(4,0,1,1,3) = 4.2, as g=3 evaluates to [(1,1,0,1),(1,1,0,2)] and playing (1,1) gives a 3-length wall(set as 4.2)
	if w == 0 && y == 0:
		return 1
	elif w == 0 && y == 0:
		return 5.0/7.0
	else:
		return randf_range(-2.5,2.5)
	

static func getClause(W : Array,t,end):
	var clause = []
	for i in range(0,W.size()):
		clause.append(W[i]**(1-2/((W[i]*t/end)**3)))
	return clause

'''
np
mp
Ap
Dp
nd
md
'''

static func pattern(p, pType, s, matchType, R) -> bool:
	var corners = [Vector2(-1,-1),Vector2(3,3), Vector2(-1,3), Vector2(3,-1)]
	var point = Vector2(p.x,p.y)
	var suffix = []
	var prefix = []
	var matches = []
	var min = 100
	var distance = 0
	var anchor_id = 0
	var anchor
	var results = []
	
	var F = [Point.EMPTY,Point.TOWER_OWN, Point.TOWER_OPPONENT, Point.BUBBLE_OWN, Point.BUBBLE_OPPONENT]
	
	if R[point.x*3+point.y].piece != F[pType]:
		return false
	
	for i in range(0,4):
		distance = abs(point.x - corners[i].x) + abs(point.y - corners[i].y)
		if distance < min:
			min = distance
			anchor_id = i
	
	anchor = corners[anchor_id]
	
	
	var w : String = ""
	for substring :String in s.split("."):
		if substring == "pD":
			w += "ndp.pnd"
		elif substring == "pA":
			w += "pn.np.mp.pm"
		else:
			w += substring + "."
			
	for substring : String in w.split(".",false):

		matches.append(Vector2(0,0))
		var acc = substring.split("p",true)
		
		if acc[0] != "":
			prefix.append_array(acc[0].split("",false))
		elif acc[1] != "":
			suffix.append_array(acc[1].split("",false))
		elif acc[0] == "" && acc[1] == "":
			continue
			
		#y = mdp, x = pmd
		#y y 
		# p
		#x x
		#
		#z = ndp, pnd = r
		#z r
		# p
		#z r
		#
		#t = mndp, h = nmdp
		# t
		#h h   
		# tp
		#   
		#
		#o = mnpnd
		#   o
		#      
		#  po
		# 
		#
		#l = dmnp = pn
		#   
		# p
		# l l  
		#
		#
		#pA = wsen = np.pn.mp.pm
		#pD = nw,se,sw,ne = ndp.dnp = mdp.dmp

		var last = "" #'d' cannot be first char
		for f in prefix:
			if f == "m":
				matches.back().x += min(abs(p.x+1-anchor.x),abs(p.x-1-anchor.x))
			elif f == "n":
				matches.back().y += min(abs(p.y+1-anchor.y),abs(p.y-1-anchor.y))
			elif f == "d":
				if last == "n":
					matches.back().x += min(abs(p.x+1-anchor.x),abs(p.x-1-anchor.x))
					matches.back().y += min(abs(p.y+1-anchor.y),abs(p.y-1-anchor.y))
					matches.append(Vector2(0,0))
					matches.back().x += max(abs(p.x+1-anchor.x),abs(p.x-1-anchor.x))
					matches.back().y += min(abs(p.y+1-anchor.y),abs(p.y-1-anchor.y))
				elif last == "m":
					matches.back().x += min(abs(p.x+1-anchor.x),abs(p.x-1-anchor.x))
					matches.back().y += min(abs(p.y+1-anchor.y),abs(p.y-1-anchor.y))
					matches.append(Vector2(0,0))
					matches.back().x += min(abs(p.x+1-anchor.x),abs(p.x-1-anchor.x))
					matches.back().y += max(abs(p.y+1-anchor.y),abs(p.y-1-anchor.y))
			last = f
		last = ""
		for g in suffix:
			if g == "m":
				matches.back().x += max(abs(p.x+1-anchor.x),abs(p.x-1-anchor.x))
			elif g == "n":
				matches.back().y += max(abs(p.y+1-anchor.y),abs(p.y-1-anchor.y))
			elif g == "d":
				if last == "n":
					matches.back().x += max(abs(p.x+1-anchor.x),abs(p.x-1-anchor.x))
					matches.back().y += max(abs(p.y+1-anchor.y),abs(p.y-1-anchor.y))
					matches.append(Vector2(0,0))
					matches.back().x += min(abs(p.x+1-anchor.x),abs(p.x-1-anchor.x))
					matches.back().y += max(abs(p.y+1-anchor.y),abs(p.y-1-anchor.y))
				elif last == "m":
					matches.back().x += max(abs(p.x+1-anchor.x),abs(p.x-1-anchor.x))
					matches.back().y += max(abs(p.y+1-anchor.y),abs(p.y-1-anchor.y))
					matches.append(Vector2(0,0))
					matches.back().x += min(abs(p.x+1-anchor.x),abs(p.x-1-anchor.x))
					matches.back().y += max(abs(p.y+1-anchor.y),abs(p.y-1-anchor.y))
			last = g
		
		for m in matches:
			var x = p.x + m.x
			var y = p.y + m.y
			results.append(Vector2(x,y))
		prefix.clear()
		suffix.clear()

	for v in results:
		if v.x < 3 && v.x > -1 && v.y < 3 && v.y > -1 && R[v.x*3 + v.y].piece != F[matchType]:
			return false
			
	return true

'''
p=(2,1)
p=1
mp=2
layer=0
=>
p=1
np.pn = -1
mp = 2
wp = 5
pD = 1.5
wp.nwp,wp.wpn = 0

2,1,1,2,0,p,1,np.pn,-1,"mp",2,"wp",5,"pD",1.5,"wp.nwp,wp.wpn",0
=
2,1,1,2,0,112,1,
p|np.pn|mp|wp|dP|wp.npw,wp.wpn
pnppnmpwpdPwpnpwwpwpn--[1,4,2,2,2,10]@[(1,2),(5,2,7)]#[(5,5)]
'''
#var test = "np.p.pn,np.mpd.mp:pn = pn"
#gnote(test,[Vector2(1,2),Vector2(0,2)])

static func gnote(state,change):
	pass

static func gnoteString(s:String, p:Array[Vector2]):
	var j = s.split(":")
	var e = [j[0].split(","),j[1].split(",")]
	var r = [e[0][0].split("."),e[0][1].split("."),e[1][0].split("."),e[1][1].split(".")]
	var R : Array[Array] = [[],[],[],[]]
	for h in range(0,4):
		var i = r[h]
		if i == "np":
			R[h].append(Vector2(p[0].x,p[0].y-1))
		if i == "pn":
			R[h].append(Vector2(p[0].x,p[0].y+1))
		if i == "mp":
			R[h].append(Vector2(p[0].x-1,p[0].y))
		if i == "pm":
			R[h].append(Vector2(p[0].x+1,p[0].y))
		if i == "fp":
			R[h].append(Vector2(p[0].x,p[0].y-2))
		if i == "pf":
			R[h].append(Vector2(p[0].x,p[0].y+2))
		if i == "wp":
			R[h].append(Vector2(p[0].x-2,p[0].y))
		if i == "pw":
			R[h].append(Vector2(p[0].x+2,p[0].y))
		if i == "pmd":
			R[h].append(Vector2(p[0].x+1,p[0].y-1))
		if i == "mpd":
			R[h].append(Vector2(p[0].x+1,p[0].y+1))
		if i == "pD":
			R[h].append(Vector2(p[0].x+1,p[0].y+1))
			R[h].append(Vector2(p[0].x+1,p[0].y-1))
			R[h].append(Vector2(p[0].x-1,p[0].y+1))
			R[h].append(Vector2(p[0].x-1,p[0].y-1))
		
	var intsc = []
	for y0 in R[0]:
		for y1 in R[0]:
			for y2 in R[1]:
				for y3 in R[0]:
					if(y1 == y0):
						intsc.append(y1)
					elif(y1==y2):
						intsc.append(y2)
					elif(y3==y2):
						intsc.append(y2)
					elif(y1==y3):
						intsc.append(y3)	
					elif(y0==y2):
						intsc.append(y2)
				
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	C.append([[0,1],[0,-1],[0,2.5],[0,-2.5],[1,1.5],[-1,-1.5],[2.5,-5],[-2.5,5]])

			
	var t = [[[0,0,0],
			[0,2.5,0],
			[0,1,0]],
	
			[[1,2,3],
			[1,5,-1],
			[2,2.2,2]]]
			
	var d = 0
	for i in range(0,3):
		for j in range(0,3):
			if(t[i][j] != 0):
				d += i + j
		
	var s = "p.pw|2.5,1|p.pm.pmn.npm.np.pn.mp.mpn.nmp|5,2.2,2,2,1,-1,2,3,1"
	
	var w = s.split("|")
	var stateL = w[0].split(".")
	var stateV = w[1].split(",")
	var changeL = w[2].split(".")
	var changeV = w[3].split(",")
	
	#C.append()
	
	[["p.pw",[2.5,1],"p.pm.pmn.npm.np.pn.mp.mpn.nmp",[5,2.2,2,2,1,-1,2,3,1]]]
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

extends Node
class_name FSystem

'''Class handling forward inference, data fitting and Q pruning'''

static var REL_LINEAR_Q_0 = []
static var REL_LINEAR_Q_1 = []
static var REL_LINEAR_Q_2 : Array[Array]
static var REL_LINEAR_Q_3 : Array[Array]

static var REL_QUADRATIC_Q_0 = []
static var REL_QUADRATIC_Q_1 = []
static var REL_QUADRATIC_Q_2 : Array[Array]
static var REL_QUADRATIC_Q_3 : Array[Array]

static var REL_SINE_Q_0 = []
static var REL_SINE_Q_1 = []
static var REL_SINE_Q_2 : Array[Array]
static var REL_SINE_Q_3 : Array[Array]

static var REL_Y1_Q_0 = []
static var REL_Y1_Q_1 = []
static var REL_Y1_Q_2 : Array[Array]
static var REL_Y1_Q_3 : Array[Array]

static var Gates : Array[Vector4]

'''Q_TABLE:
	element i,j = float value designating success of R_waypoint(m_i,m_j)'''
static var Q_TABLE = []
#ofunc format: [a0,a1,a2,a3,a4,a5]
static var SP = []
#100 best elements of REL = [[id,direction,feasibility],[id,direction,feasibility],...] are put onto Q_TABLE
#x-axis(decreasing): better direction
#y-axis(decreasing): better feasibility 
static var REL = {}

#REL_Q_0[3456][4531] = 2.7859834
#RELL_Q_1[6*9 + 9 + 62*14] = 57710012,  RELL[6,9,14] the layer-7, at i=2,j=2, at dpu=14 is 5.771x + 12
#5 8782 0091 is 5xx + 8782x + 0091

static func randomize_tables(n : int):
	seed(n)
	for i in range(0,10):
		REL_LINEAR_Q_0.append(randi() % 9999999999999999)
	for i in range(0,6300):
		REL_LINEAR_Q_1.append(randi() % 9999999999999999)
	for i in range(0,6300):
		var A = []
		for j in range(0,6300):
			A.append(randi() % 9999999999999999)
		REL_LINEAR_Q_2.append(A)
	for i in range(0,10):
		var A=[]
		for j in range(0,6300):
			A.append(randi() % 9999999999999999)
		REL_LINEAR_Q_3.append(A)
		
static func convert(n):
	var a1 = floori(n / 1000)
	var a0 = floori(1000*((n / 1000) % 1))
	return [a0,a1]
		
		
static func initSP():
	for i in range(0,4):
		var A = [i]
		for j in range(1,i+2):
			A.append(randf_range(-2.0,2.0))
		SP.append_array(A)


#rank REL onto Q
static func update_Q():
	pass

#Vector4(metric1,metric2,upperLeftCornerPoint,lowerRightCornerPoint)
# m1 = layer*i*j, 9*7 = 63


static func getWaypointTarget(w_index,w_target):
	var plane : Array[Array]
	
	for i in range(0,100):
		var temp = []
		for j in range(0,100):
			temp.append(0)
		plane.append(temp)
		
	var L = []
	var min = 1000
	var temp
	for X in range(0,63):
		for Y in range(0,63):
			var counter = 0
			var p1
			var p2
			while(counter < 100):
				p1 = randi_range(0,99)
				p2 = randi_range(0,99)
				var i1 = (X % 9) % 3
				var j1 = (X % 9) / 3
				var y1 = X / 9
				var i2 = (Y % 9) % 3
				var j2 = (Y % 9) / 3
				var y2 = Y / 9
				temp = p1*GSystem.wInft(w_index,y1,i1,j1,0) + p2*GSystem.wInft(w_index,y2,i2,j2,0) - w_target
				plane[p1][p2] = temp
				if(temp < min):
					min = temp
					L.clear()
					L.append_array([X,Y,p1,p2])
				counter += 1

		
	return [Vector4i(L[0],L[1],(L[2]-3)*10**2+10**6*(L[3]+3),(L[2]+3)*10**2+10**6*(L[3]-3))]

static func distToTarget(x,y,points):
	
	var sum =0
	
	for i in range(0,4):
		sum += (points[i].x - x) + (points[i].y - y)
		
	return sum - 2*((points[0].x - points[1].x)/2.0 + (points[0].y - points[3].y)/2.0)


static func getArea(metricPlaneZ,metricPlaneW):
	var a1 = Vector2((1.0/10**2)*floor(metricPlaneZ/10**4),10**2*fmod(metricPlaneZ/10**4,1.0))
	var a2 = Vector2((1.0/10**2)*floor(metricPlaneZ/10**4),10**2*fmod(metricPlaneW/10**4,1.0))
	var a3 = Vector2((1.0/10**2)*floor(metricPlaneW/10**4),10**2*fmod(metricPlaneW/10**4,1.0))
	var a4 = Vector2((1.0/10**2)*floor(metricPlaneW/10**4),10**2*fmod(metricPlaneZ/10**4,1.0))
	return [a1,a2,a3,a4]

static func generatePath(dpu, metricPlane, dxMin, dyMin, WTime,p):
	var path : Array = [Vector2(metricPlane.x,metricPlane.y)]
	var x = p.x
	var y = p.y
	var points = getArea(metricPlane.z,metricPlane.w)
	var dR = computeTurnedVector(points,x,y)
	
	print("computing path to waypoint_target for dpu: ",dpu.id)
	var counter = 0
	while(distToTarget(x,y,points) > 0 && counter < 2):
		var startVector = Vector2(dxMin,1)
		x = dpu.inference_generic(x,y,metricPlane,startVector,dR,WTime)
		startVector = Vector2(1,dyMin)
		y = dpu.inference_generic(x,y,metricPlane,startVector,dR,WTime)
		path.append(Vector2(x,y))
		counter += 1
	return path

static func computeTurnedVector(points,x,y):
	var temp_x = 10000
	for a in points:
		if(a.x + x)/2 < temp_x:
			temp_x = (a.x + x)/2
			
	var temp_y = 10000
	for a in points:
		if(a.x + x)/2 < temp_y:
			temp_y = (a.x + x)/2
	
	var dR = Vector2(temp_x,temp_y)
	
	if x > points[3].x && x < points[2].x:
		dR.x = 0

	if y < points[0].y && y > points[3].y:
		dR.y = 0
		
	return dR

static func computeError(dpu,metricPlane,tTime):
	var angle = 0
	var angleAdd = 2/7*PI
	var dx
	var dy
	var p = Vector2(dpu.get_points()[metricPlane.x % 9].score[metricPlane.x / 9], dpu.get_points()[metricPlane.y % 9].score[metricPlane.y / 9])
	var targetVector = Vector2(1,1)#FSystem.AVGLocalVector(dpu,metricPlane.x,metricPlane.y)
	var z_min : Array
	var temp = 100000
	var radius = Parameters.BW_PHASE_RADIUS
	var startVector =  Vector2(1,1)#FSystem.AVGLocalVector(dpu,metricPlane.x,metricPlane.y)
	
	for i in range(0,7):
		dx = radius*cos(angle)
		dy = radius*sin(angle)
		angle += angleAdd
		var errorx= dpu.inference_generic_backward(p.x,p.y,metricPlane,startVector,targetVector,tTime,dx)
		var errory =dpu.inference_generic_backward(p.x,p.y,metricPlane,startVector,targetVector,tTime,dy)
		#print("errors ",errorx," ",errory)
		if(errorx + errory < temp):
			z_min.clear()
			z_min.append(dx)
			z_min.append(dy)
			z_min.append(errorx+errory)
	
	return z_min


	
#returns SP function f such that f(0) = p1, f(1) = p2 in form [[SP[i][0],SP[i][1],...],[SP[i][7],SP[i][8],...]]
static func interpolatePoint(p1,p2):
	var sum1 = 0
	var sum2 = 0
	var r_c1 = []
	var r_c2 = []
	sum1 = -p1.x + p2.x
	r_c1.append(-p1.x+p2.x)
	#solve for highest order coeff
	for c in range(0,6):
		sum1 += SP[0][c]**c
		r_c1.append(SP[0][c])
	r_c1.append(sum1)
	
	sum2 = -p1.y + p2.y
	r_c2.append(-p1.y + p2.y)
	for c in range(0,6):
		sum2 += SP[0][c+7]**c
		r_c2.append(SP[0][c+7])
	r_c2.append(sum2)
	
	return [r_c1,r_c2]
	
#returns SP function f such that f'(0) = vec1, f'(1) = vec2
static func interpolateVector(vec1,vec2):
	var R1 = []
	var R2 = []
	#SCHEME #1, replace a0 term by vec1.x, solve for vec2.x by lowest-term-exchange
	var coeff = getSPElement(vec1,vec2)
	coeff[5] = vec1.x
	var sum = 0
	for c in range(0,3): #lowest term a1 is left out
		sum += c
	coeff[4] = vec2.x - sum - coeff[5]#lowest term a1 is exchanged
	
	for i in range(0,5):
		R1.append(coeff[i+1]**(5-i)/(5-i))
		
	R1.append(0)
	
	var coeff2 = getSPElement(vec1,vec2)
	coeff2[5] = vec1.y
	sum = 0
	for c in range(0,3): #lowest term a1 is left out
		sum += c
	coeff2[4] = vec2.y - sum - coeff2[5]#lowest term a1 is exchanged
	
	for i in range(0,5):
		R2.append(coeff2[i+1]**(5-i)/(5-i))
		
	R2.append(0)
	#print("interpolation complete: R1 = ",R1," R2 = ",R2)
	return [R1,R2]
	
static func evaluateAtT(R,t):
	var result = 0
	for i in range(0,R.size()):
		result += R[i]*t**(5 - i)
	return result
		
static func evaluateAtMidpoint(R1,R2):
	var y = 0

	for i in range(0,6):
		y += R1[i]
		
	var middle = y / 2.0
	var K = 10
	while(true):
		var h = 0.0
		for u in range(0,K):
			h += 1.0 / K
			var temp = 0
			for i in range(0,6):
				temp += R1[i]*h**(5-i)
			if (middle-temp)*50 < 1.0:
				var temp2 = 0
				for k in range(0,6):
					temp2 += R2[k]
				return temp2
			temp = 0
		K *= 10

	
#returns [0,a4,a3,a2,a1,a0]
static func getSPElement(v1 : Vector2, v2 : Vector2):
	return [0,-5,7,-1,-3,3]
	#for i in range(0,10,0.1):
		#if is_equal_approx(MathLib.getDVector(SP[0],i).x, v1.x) && is_equal_approx(MathLib.getDVector(SP[0],i).y, v1.y):
			#pass
	#return SP[0]

static func getTime(W):
	pass

static func get_ap_at_x(n,value,coeff):
	if n == 0:
		return coeff*value #x
	elif n == 1:
		return -coeff*value #-x
	elif n == 2:
		return coeff * value * value#x*x
	elif n == 3:
		return coeff#y=coeff
	elif n == 4:
		return coeff*sin(value)#sinx
	elif n == 5:
		return coeff*log(value)#lnx
	elif n == 6:
		return coeff*10*sin(value) / value + log(value) #Y1 "APPROXIMATOR"
	elif n == 7:
		return coeff*pow(-1*(-value-5)**2 + 100/(value+1),1/7)#Y2 "STEP"




static func initialize():
	SP.append([0,1,0,0,3,0,0,1,-1,0,0,0,0,0])
	SP.append([0.5,1,0.5,0,3,0,2,0,-2,0.33,0,0,0,0])


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

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
static var Q_TABLE : Array[Array]

static var SP : Array[Array]

#static func createGate()
#ofunc format: [id,a0,a1,a2,a3,a4,a5]

static func eval(spFunction : Array, t):
	pass

static func fit(data : Array[Point]):
	pass
	
static func transform():
	pass

static func syntheticFFx(ofunc_id):
	pass
	
static func prune():
	pass

static func getRelation(dpu):
	pass
	
#return [metric1,metric2,upperLeftCornerPoint,lowerRightCornerPoint] m1 = layer*i*j, 9*7 = 63
static func getWaypointTarget(currentDpu,W) -> Vector4:
	return Vector4(1,2,1,2)

static func getVTarget(R:Vector4, W : float):
	pass
	
static func getVVector(W:float):
	pass

static func generatePath(dpu, metricPlane, dxMin, dyMin, WTime,p):
	var path : Array = [Vector2(metricPlane.x,metricPlane.y)]
	var dR : Vector2 #TODO
	var x = p.x
	var y = p.y
	var startVector = FSystem.AVGLocalVector(dpu,metricPlane.x,metricPlane.y)
	var counter = 0
	while(!isWithinTarget(x,y,metricPlane) && counter < 125):
		x = dpu.inference_generic(x,y,metricPlane,startVector,dR,dxMin,WTime)
		y = dpu.inference_generic(x,y,metricPlane,startVector,dR,dyMin,WTime)
		path.append(Vector2(x,y))
		counter += 1
	return path

static func isWithinTarget(x,y,R):
	pass

static func computeError(dpu,metricPlane,tTime):
	var angle = 0
	var angleAdd = 2/7*PI
	var dx
	var dy
	var p = Vector2(dpu.get_points()[metricPlane.x % 9+(metricPlane.x / 9)*3].score[metricPlane.x % 7], dpu.get_points()[metricPlane.y % 9+(metricPlane.y / 9)*3].score[metricPlane.y % 7])
	var targetVector = FSystem.AVGLocalVector(dpu,metricPlane.x,metricPlane.y)
	var z_min : Array
	var temp = 100000
	var radius = Parameters.BW_PHASE_R
	var startVector = FSystem.AVGLocalVector(dpu,metricPlane.x,metricPlane.y)
	
	for i in range(0,7):
		dx = radius*cos(angle)
		dy = radius*sin(angle)
		angle += angleAdd
		var errorx= dpu.inference_generic_backward(p.x,p.y,metricPlane,startVector,targetVector,tTime,dx)
		var errory =dpu.inference_generic_backward(p.x,p.y,metricPlane,startVector,targetVector,tTime,dy)
		if(errorx + errory < temp):
			z_min.clear()
			z_min.append(dx)
			z_min.append(dy)
			z_min.append(errorx+errory)
	
	return z_min

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


static func AVGLocalVector(dpu,metric1,metric2):
	dpu.get_points()
	

static func interpolate(v1 : Vector2,v2 : Vector2,t) -> float:
	var y
	for i in range(0,10,0.1):
		if is_equal_approx(MathLib.getDVector(SP[0],i).x, v1.x) && is_equal_approx(MathLib.getDVector(SP[0],i).y, v1.y):
			pass
	for i in range(1,7):
		y += SP[0][i]*t
	return y
	
static func getSPElement(v1 : Vector2, v2 : Vector2):
	for i in range(0,10,0.1):
		if is_equal_approx(MathLib.getDVector(SP[0],i).x, v1.x) && is_equal_approx(MathLib.getDVector(SP[0],i).y, v1.y):
			pass
	return SP[0]

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

	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

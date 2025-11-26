extends Node
class_name MathLib

static var J = []

static func computeMetricM1(Z1,Z2):
	return det(mult(Z1,inv(Z2)))-det(mult(Z2,inv(Z1)))

static func mult(M,N):
	var O = []
	var sum = 0
	var n = sqrt(len(N)) as int
	for i in range(0,n):
		for j in range(0,n):
			for k in range(0,n):
				sum += M[k+n*i]*N[j+n*k]
			O.append(sum)
			sum = 0
	return O

static func add(from,to,scalar,A):
	J[from + to*7] = scalar
	return mult(J,A)

static func scalar_multiply(c,A):
	for i in range(len(A)):
		A[i] *= c
	return A


static func transpose(N):
	var U = []
	var n = sqrt(len(N)) as int
	for i in range(n):
		for j in range(n):
			U.append(N[n*j + i])
	return U

static func inv(N):
	var d = det(N)
	#print(J[0],d,J[0]*1/d)
	return scalar_multiply(1/d,transpose(J))

static func det(N):
	var a = []
	var temp = []
	var result = 0
	var n = sqrt(len(N)) as int
	
	if(len(N)==4):
		return N[0]*N[3] - N[1]*N[2]

	for index in range(n):
		for i in range(n):
			for j in range(n):
				a.append(N[index*n + j])
			#print(a)
			for k in range(len(N)):
				if(floori(k / n) != index && k%n != i):
					temp.append(N[k])
				#print(temp)
		
			var sign = pow(-1,i) if index % 2 == 0 else pow(-1,i+1)
			var t = det(temp)*sign
			#print("t",t)
			
			if(n == 3):
				J.append(t)
				#print("adding: ",t)
			
			if(index == 0):
				#print("a[i]",a[i])
				result += a[i]*t
				#print("result",result)
			a.clear()
			temp.clear()
	#print(J)
			
	return result
#(vector0.x,vector0.y) 
#(vec
static func getAngularError(v1:Vector2,v2:Vector2):
	v2.x += v1.x - v2.x
	v2.y += v1.y - v2.y
	
	v1 = v1.normalized()
	v2 = v2.normalized()
	
	

#ofunc format: [id,a0,a1,a2,a3,a4,a5]
static func getDVector(ofunc:Array,x) -> Vector2:
	var dy = 0
	if(ofunc[0] < 16):
		for i in range(1,7):
			dy += i*ofunc[i+1]*(x**(i-1))
	else:
		if(ofunc[0] == 16): #sin(x)
			dy = ofunc[2]*ofunc[1]*cos(ofunc[2]*x)
		elif(ofunc[0] == 17): #exp(x)
			dy = ofunc[1]*exp(ofunc[2]*x)
	return Vector2(1,dy)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

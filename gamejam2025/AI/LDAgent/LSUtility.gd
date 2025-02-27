extends Node
class_name MathLib

static var J = []

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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

extends Node
class_name Group


var L : Array[int]

var G = [[0,0,0],[0,0,0],[0,0,0]]

'''
G[x][y] += tileType*10
G[1][2] = 
'''

# Add 'type' piece to the Group
func add(posX,posY,type):
	G[posX][posY] = type*10

func access():
	return G

###########################

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

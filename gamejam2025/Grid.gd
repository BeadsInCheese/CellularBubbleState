extends Sprite2D


@export
var bubble = preload("Bubble.tscn")
@export
var xsize : int = 20
@export
var ysize : int = 20

var gridList=[]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(xsize):
		for j in range(ysize):
			var x:Bubble=bubble.instantiate()
			x.tileType=0
			
			add_child(x)
			gridList.append(x)
	
	
func automata_step() -> void:
	for i in range(len(gridList)):
		var xpos:int=i%xsize
		var ypos:int=i/ysize
		
		pass
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

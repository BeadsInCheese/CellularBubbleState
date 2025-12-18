extends "res://AI/AgentBase.gd"

class_name RandomAI

func makeMove(observation:Board):
	var x=randi()%100
	var offset=0
	
	if(observation == null or not observation.exists()):
		return
	
	await observation.get_tree().create_timer(0.10).timeout
	
	for i in range(x):
		while(observation.gridList[(i+offset)%len(observation.gridList)].tileType!=0):
			offset+=1
			if(offset>100000 or observation == null):
				return

	observation.gridList[(x+offset-1)%len(observation.gridList)].setTileType(playerType)
	moveMade.emit(observation)

	Console.instance.write("Larry","observe and learn.")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func get_custom_class_name():
	return "RandomAI"

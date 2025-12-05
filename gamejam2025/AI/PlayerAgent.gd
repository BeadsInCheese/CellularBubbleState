extends "res://AI/AgentBase.gd"

class_name PlayerAgent
# Called when the node enters the scene tree for the first time.
#var makingMove=false

func makeMove(observation:Board):
	makingMove=true
	
	#print("latest tile index: " + str(observation.latestTileIndex))

	if observation.tutorial:
		observation.get_node("Node2D").sequence

	while makingMove:
		if(observation!=null):
			if(skip):
				await makeRandomMove(observation)
				if(!Board.boardExists):
					return
				await observation.get_tree().process_frame
				if(!Board.boardExists):
					return
				break
			await observation.get_tree().process_frame
			if(!Board.boardExists):
				return
		else:
			return
		#print((makingMove))
	moveMade.emit(observation)
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func get_custom_class_name():
	return "PlayerAgent"
func get_is_player() -> bool:
	return true

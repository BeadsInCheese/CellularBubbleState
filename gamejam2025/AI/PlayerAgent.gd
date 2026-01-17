extends "res://AI/AgentBase.gd"

class_name PlayerAgent
# Called when the node enters the scene tree for the first time.
#var makingMove=false

func makeMove(observation:Board):
	makingMove=true
	
	if observation.tutorial:
		observation.get_node("Node2D").sequence

	while makingMove:
		if(observation != null and observation.get_tree() != null):
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

	moveMade.emit(observation)


func get_custom_class_name():
	return "PlayerAgent"
func get_is_player() -> bool:
	return true

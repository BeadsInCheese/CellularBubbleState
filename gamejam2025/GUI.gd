extends Node
class_name GUI

func updateSidebar(turn,score1,score2):
	$Score_player1.text = str(score1)
	$Score_player2.text = str(score2)
	#print("Gui debug")
	#print($Score_player1)
	#print(score2)
	#print(turn)
	if(turn == 1):
		$TurnValue.text="Player 1 turn"
	elif(turn == 3):
		$TurnValue.text="Player 2 turn"
	else:
		$TurnValue.text="Automata turn"
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

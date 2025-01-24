extends Node


func updateSidebar(turn,score1,score2):
	$Score_player1.text = str(score1)
	$Score_player2.text = str(score2)
	
	if(turn == 1):
		$TurnValue.set_text("Player 1 turn")
	elif(turn == 3):
		$TurnValue.set_text("Player 2 turn")
	else:
		$TurnValue.set_text("Automata turn")
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

extends Node2D

var gameBoard
var tStage
var tPrompts = ["Play at X to start",
"OK...I'll start here!",
"I need bubble D:",
"Play at X, creating new bubble from two towers",
"Now, play at X to create an extension from your bubble!",
"I'll also do this!! :)",
"Quiet move :O",
"Playing at X you'll see how multiple rules are applied!",
"Finally, play at X, and see what happens",
"I am gonna block here!",
"Diagonal rule is applied to create new bubble!",
"You have finished the Tutorial!"]

#var puzzle = "C4,F11,H3,D2,A3"

static var sequence = [66,43,67,64,64,43,90,78,89,90,51]
static var totalSequence = [66,43,-1,67,64,-1,64,43,-1,90,78,-1,89,90,-1,51]
var markerPlacementTurn = [0,4,6,10,12]
var cleanUpTurn = [1,7,13]
var automataTurn = [2,5,8,11,14]
var turn
'''turn = 0, 'X' at 66 "Play at X to start"
turn = 1, bot, play at 43, remove at 66, "OK...I'll start here!"
turn = 2 automata
turn = 3, bot, play at 67, "I need bubble D:"
turn = 4, 'x' at 64, "Play at X, creating new bubble from two towers",
turn = 5, automata
turn = 6, 'x' at 64, "Now, play at X to create extension from your bubble!",
turn = 7, bot, play at 43, remove at 64, "I'll also do this!! :)",
turn = 8, automata
turn = 9, bot, play at 90, "Quiet move :O",
turn = 10, 'X' at 78, Playing at X you'll see how multiple rules are applied!",
turn = 11, automata
turn = 12, 'X' at 89, "Finally, play at X, and see what happens",
turn = 13, bot, play at 90, remove at 89, "Playing here"
turn = 14, automata
turn = 15, bot, play at 51, "Diagonal rule is applied to create new bubble!"
turn = 16, "You have finished Basic Tutorial!!"
'''


func convertSquare(s:String):
	return 12*(s.unicode_at(0)-1) + s[1].to_int() - 1

func createPuzzle(s:String):
	var i = 0
	for c in s.split(","):
		sequence[i] = convertSquare(c)
		i += 1

func turnChanged() -> void:
	print("turn=",turn," tStage=",tStage)
	if(automataTurn.find(turn) == -1): #not automata turn
		if(cleanUpTurn.find(turn) != -1): #is it time to remove 'X' markers on Board?
			gameBoard.gridList[sequence[tStage-1]].get_node("Button").text=""
		if(markerPlacementTurn.find(turn) != -1): #is it time to place 'X' marker?
			gameBoard.gridList[sequence[tStage]].get_node("Button").text="X"
			
		#handle text prompts using different index, tStage
		gameBoard.get_tree().root.get_node("root/Board/Node2D/text").text=tPrompts[tStage]
		tStage += 1
	turn += 1
	
	if(turn == 16):
		$Exit.visible = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gameBoard = get_tree().root.get_node("root/Board")
	gameBoard.gridList[sequence[0]].get_node("Button").text="X"
	gameBoard.turnChangedSignal.connect(turnChanged)
	gameBoard.get_tree().root.get_node("root/Board/Node2D/text").text=tPrompts[0]
	tStage = 1
	turn = 1



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_exit_button_down() -> void:
	SceneNavigation._on_PlayerMenuPressed()

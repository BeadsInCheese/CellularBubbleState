extends AgentBase

class_name AutomataAgent

func makeMove(observation:Board):
	if observation == null or not observation.exists():
		return

	await observation.get_tree().create_timer(0.20).timeout
	game_board = observation
	automata_step()
	moveMade.emit(game_board)

static var automata:Automata=null

func init(board:Board):
	game_board=board
	automata=board.get_child(0)
	automata.printRules()
	

var game_board: Board
	
func get_custom_class_name():
	return "AutomataAgent"
	
	
func automata_step() -> void:
	if game_board == null or not game_board.exists():
		return

	var baseGrid = game_board.getBoardCopy()
	var tempGrid = baseGrid.duplicate(true)
	var result=automata.AutomataStep(tempGrid)
	
	for i in len(tempGrid):
		var currentTile = game_board.gridList[i].tileType
		var newTile = tempGrid[i]
		
		if currentTile != newTile:
			game_board.gridList[i].setTileType(newTile, true)

static func simulateAutomataStep(board: Array):
	board = automata.AutomataStep(board)

static func simulateAutomataStepAndReturnActions(board: Array) -> Array:
	var oldBoard = board.duplicate()
	var newBoard = automata.AutomataStep(board)
	var automataActions = []
	
	for i in len(oldBoard):
		var oldTile = oldBoard[i]
		var newTile = newBoard[i]
		
		if oldTile != newTile:
			automataActions.append([i, newTile, oldTile])
	
	return [newBoard, automataActions]

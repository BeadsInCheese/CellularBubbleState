extends AgentBase

class_name AutomataAgent
static var  loadCustomRuleset:bool=false
static var ruleset:Array
func makeMove(observation:Board):
	if observation == null or not observation.exists():
		return

	await observation.get_tree().create_timer(0.20).timeout
	game_board = observation
	automata_step()
	moveMade.emit(game_board)

static var automata:Automata=null

func loadRuleset():
	automata.clearRuleset()
	for rule in ruleset:
		automata.addRule(rule[0],rule[1])
	automata.compileRuleset()
func fastStep(board:PackedByteArray):
	return automata.AutomataStepPackedByte(board)
func packedByteToArray(arr:PackedByteArray):
	var ret=[]
	for i in arr:
		ret.append(i)
	return ret
func init(board:Board):
	game_board=board
	automata=board.get_child(0)
	
	automata.printRules()
	if loadCustomRuleset:
		loadRuleset()
	#automata.clearRuleset()
	#automata.addRule([1,1,1, 1,1,1, 1,1,1],0)
	#automata.compileRuleset()
	#automata.printRules()
	#automata.stats()
	#var test:PackedByteArray=PackedByteArray(board.asArray())
	#fastStep(test)
var game_board: Board
	
func get_custom_class_name():
	return "AutomataAgent"
	
	
func automata_step() -> void:
	if game_board == null or not game_board.exists():
		return

	var baseGrid = game_board.getBoardCopy()
	var tempGrid = baseGrid.duplicate(true)
	automata.AutomataStep(tempGrid)
	#tempGrid = automata.AutomataStepPackedByte(tempGrid) 

	

	for i in len(tempGrid):
		var currentTile = game_board.gridList[i].tileType
		var newTile = tempGrid[i]
		
		if currentTile != newTile:
			game_board.gridList[i].setTileType(newTile, true)

static func simulateAutomataStep(board: PackedByteArray):
	board = automata.AutomataStepPackedByte(board)

static func simulateAutomataStepAndReturnActions(board: PackedByteArray) -> Array:

	#var newBoard = automata.AutomataStepPackedByte(board)
	#var automataActions = []
	
	#for i in len(oldBoard):
	#	var oldTile = oldBoard[i]
	#	var newTile = newBoard[i]
	#	
	#	if oldTile != newTile:
	#		automataActions.append([i, newTile, oldTile])
	var changes=[]
	board=automata.simulateAutomataStepAndReturnActions(board,changes)
	return changes#[newBoard, automataActions]

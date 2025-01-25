extends Sprite2D

class_name Board
@export
var bubble = preload("Bubble.tscn")
@export
var gui :GUI
@export
var xsize : int = 17
@export
var ysize : int = 17

var gridList: Array[Bubble] = []
enum Players{PLAYER1=1,PLAYER2=3,AUTOMATA=0}
var turnOrder=[Players.PLAYER1,Players.PLAYER2,Players.AUTOMATA,Players.PLAYER2,Players.PLAYER1,Players.AUTOMATA]
var currentTurn=0
var player1Score = 0
var player2Score = 0

#debug
var testxpos = 1
var testypos = 1
var testxmark = -1
var testymark = -1

func updateScore():
	player1Score=0
	player2Score=0
	for i in gridList:
		if(i.tileType==1 or i.tileType== 2):
			player1Score+=1
		if(i.tileType==3 or i.tileType == 4):
			player2Score+=1
			
func changeTurn()->void:
	currentTurn=(currentTurn+1)%6
	
	if(turnOrder[currentTurn]==Players.AUTOMATA):
		automata_step()
		changeTurn()
	updateScore()
	gui.updateSidebar(turnOrder[currentTurn],player1Score,player2Score)
	
	checkRule(rules.keys()[0], 0, testxpos, testypos, testxmark, testymark)
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(xsize):
		for j in range(ysize):
			var x:Bubble=bubble.instantiate()
			x.tileType=0
			
			add_child(x)
			gridList.append(x)
	moveToplace()
	
	checkRule(rules.keys()[0], 0, testxpos, testypos, testxmark, testymark)
	
	flipMatchGrid([[1,2], [3,4]])


func moveToplace()->void:
	for i in range(len(gridList)):
		var xpos:int=i%xsize
		var ypos:int=i/ysize
		gridList[i].position=Vector2(xpos,ypos)*38+Vector2(20,20)
func automata_step() -> void:
	for i in range(len(gridList)):
		var xpos:int=i%xsize
		var ypos:int=i/ysize
		
		pass
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_button_down() -> void:
	player1Score = player1Score+1
	changeTurn()
	automata_step()

func getGridTileType(xpos: int, ypos: int):
	if xpos < 0 or ypos < 0 or xpos >= xsize or ypos >= ysize:
		return null

	return gridList[xpos + ypos * ysize].tileType

func checkRule(matchGrid: Array, matchResult: int, xpos: int, ypos: int, xmark: int, ymark: int) -> bool:
	for j in range(len(matchGrid)):
		for i in range(len(matchGrid[0])):
			print(i, j, "  ", matchGrid[i][j], " ", getGridTileType(i + xpos + xmark, j + ypos + ymark))

	return false

func checkAllRules():
	for matchGrid in rules.keys():
		var matchResult = rules[matchGrid]
		

func flipMatchGrid(matchGrid: Array):
	var grid = matchGrid
	print(grid)
	for i in range(4):
		grid = rotateGrid(grid)
		print(grid)

func rotateGrid(grid):
	if len(grid) == 2:
		return rotate2x2Grid(grid)
	elif len(grid) == 1:
		return rotate1x3Grid(grid)
	elif len(grid) == 3 and len(grid[0]) == 1:
		return rotate3x1Grid(grid)
	else:
		return rotate3x3Grid(grid)

func rotate2x2Grid(grid):
	return [[grid[0][1], grid[1][1]], [grid[0][0], grid[1][0]]]

func rotate3x1Grid(grid):
	return [[grid[2][0], grid[1][0], grid[0][0]]]
	
func rotate1x3Grid(grid):
	return [[grid[0][0]], [grid[0][1]], [grid[0][2]]]

func rotate3x3Grid(grid):
	var result = []
	for i in range(3):
		result.append([])
		for j in range(3):
			result[-1].append(grid[j][2-i])
	return result

var o = null # shortcut for Any
var t = -1   # shortcut for Tower
var b = -2   # shortcut for Bubble
var rules: Dictionary = {
	[
		[ 2, 4],
		[ 4, o]
	]: 0,
	
	[
		[ 0, b],
		[ t, b]
	]: b,
	[
		[ b, b],
		[ 0, t]
	]: 0,
	
	[
		[ o, o, o],
		[ b, b, b],
		[ o, t, o]
	]: 0,
	
	[
		[0],
		[b],
		[t]
	]: b,
	
	[
		[ o, t, o],
		[ o, 0, o],
		[ o, t, o]
	]: b,
	[
		[t],
		[0],
		[t]
	]: 0,
	
	[
		[ 0, t],
		[ t, b]
	]: b
}

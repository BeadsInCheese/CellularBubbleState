extends Node2D
class_name Bubble
var tileType=1
var board:Board
var tileIndex=0

func setTileType(type, is_automata: bool = false):
	tileType=type
	update_gfx(tileType)
	
	if not is_automata:
		board.latestAutomataIndexes.clear()
		board.latestTileIndexes.append(tileIndex)
		if len(board.latestTileIndexes) > 3:
			board.latestTileIndexes.pop_front()
	if is_automata:
		board.latestAutomataIndexes.append(tileIndex)
	
	for bubble in board.gridList:
		bubble.update_highlight_gfx()

var appearing = false

func appear():
	appearing = true
	$AudioStreamPlayer2D.play()
	for i in range(100):
		$BubbleGfx.material.set_shader_parameter("treshold",0.05*(10-i))
		if is_inside_tree() and get_tree()!=null:
			await get_tree().process_frame
		else:
			return
		if not appearing:
			return

func disappear():
	appearing = false
	$AudioStreamPlayer2D.play()
	for i in range(100):
		$BubbleGfx.material.set_shader_parameter("treshold",0.05*(i))
		if is_inside_tree() and get_tree()!=null:
			await get_tree().process_frame
		else:
			return
		if appearing:
			return
func update_gfx(type):
	#print("update called "+str(type))
	$Button.visible=false
	$BubbleGfx.material.set_shader_parameter("type",type)
	$BubbleGfx.material.set_shader_parameter("offset",randf()*100)
	$BubbleGfx.material.set_shader_parameter("angle",21)
	if type == 1:
		$BubbleGfx.material.set_shader_parameter("color",Vector3(0,0,1))
		$BubbleGfx.set_texture(load("res://resources/GFX/towers/pillar_player1.png"))
		$BubbleGfx.scale=Vector2(0.08,0.08)
		appear()
	elif type == 3:
		$BubbleGfx.material.set_shader_parameter("color",Vector3(1,0,0))
		$BubbleGfx.set_texture(load("res://resources/GFX/towers/pillar_player2.png"))
		$BubbleGfx.scale=Vector2(0.08,0.08)
		appear()
	elif type == 2:
		$BubbleGfx.material.set_shader_parameter("color",Vector3(0,0,1))
		$BubbleGfx.set_texture(load("res://resources/GFX/Bubble icons/bubble03b.png"))
		$BubbleGfx.scale=Vector2(0.2,0.2)
		appear()
	elif type == 4:
		$BubbleGfx.material.set_shader_parameter("color",Vector3(1,0,0))
		$BubbleGfx.set_texture(load("res://resources/GFX/Bubble icons/bubble03b_2.png"))
		$BubbleGfx.scale=Vector2(0.2,0.2)
		appear()
	elif type == 0:
		disappear()
		#$BubbleGfx.set_texture(null)
		$Button.visible=true

func update_highlight_gfx():
	var is_latest_tower = (len(board.latestTileIndexes) > 0 and tileIndex == board.latestTileIndexes[len(board.latestTileIndexes) - 1])
	var is_latest_automata = tileIndex in board.latestAutomataIndexes
	$BubbleGfx.material.set_shader_parameter("highlight", 1.0 if is_latest_tower or is_latest_automata else 0.9)
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	board=get_tree().get_root().get_node("root/Board")
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$RichTextLabel.text="[center]"+str(tileType)+"[/center]"


func _on_button_button_down() -> void:
	if(board.currentBoardStatePointer < len(board.boardHistory)-1):
		return
	
	var seq 
	var turn
	
	if board.get_node_or_null("Node2D") != null:
		seq = board.get_node("Node2D").totalSequence
		turn = board.get_node("Node2D").turn
		if(len(seq)>turn-1):
			if(board.tutorial and seq[turn-1] != tileIndex):
				return
	
	if(board.turnOrder[board.currentTurn].get_is_player()==true and not(board.turnOrder[board.currentTurn].skip)):
		setTileType(board.turnOrder[board.currentTurn].playerType)
		board.lastMove=[tileIndex,board.turnOrder[board.currentTurn].playerType]
		board.turnOrder[board.currentTurn].makingMove=false
	
	pass # Replace with function body.

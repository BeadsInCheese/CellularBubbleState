extends Node2D
class_name Bubble
var tileType=1
var board:Board
var tileIndex=0

func setTileType(type, is_automata: bool = false):
	tileType=type
	update_gfx(tileType)
	
	if not is_automata:
		board.latestTileIndexes.append(tileIndex)
		if len(board.latestTileIndexes) > 2:
			board.latestTileIndexes.pop_front()

var appearing = false

func appear():
	appearing = true
	$AudioStreamPlayer2D.play()
	for i in range(100):
		$BubbleGfx.material.set_shader_parameter("treshold",0.05*(10-i))
		if get_tree()!=null:
			await get_tree().process_frame
		if not appearing:
			return
			
	appearing = false

func disappear():
	appearing = false
	
	$AudioStreamPlayer2D.play()
	for i in range(100):
		$BubbleGfx.material.set_shader_parameter("treshold",0.05*(i))
		if get_tree()!=null:
			await get_tree().process_frame

func update_gfx(type):
	#print("update called "+str(type))
	$Button.visible=false
	
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
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	board=get_tree().get_root().get_node("root/Board")
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$RichTextLabel.text="[center]"+str(tileType)+"[/center]"


func _on_button_button_down() -> void:
	print("clicked bubble, player=",board.turnOrder[board.currentTurn].playerType)
	if(board.currentBoardStatePointer < len(board.boardHistory)-1):
		return
	if(board.turnOrder[board.currentTurn].get_is_player()==true and not(board.turnOrder[board.currentTurn].skip)):
		setTileType(board.turnOrder[board.currentTurn].playerType)
		board.lastMove=[tileIndex,board.turnOrder[board.currentTurn].playerType]
		board.turnOrder[board.currentTurn].makingMove=false
		
	pass # Replace with function body.

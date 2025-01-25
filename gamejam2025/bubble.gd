extends Node2D
class_name Bubble
var tileType=1
var board:Board

func setTileType(type):
	tileType=type
	update_gfx(tileType)

func appear():
	$AudioStreamPlayer2D.play()
	for i in range(100):
		$BubbleGfx.material.set_shader_parameter("treshold",0.05*(10-i))
		await get_tree().process_frame

func update_gfx(type):
	#print("update called "+str(type))
	$Button.visible=false
	
	if type == 1:
		$BubbleGfx.set_texture(load("res://resources/pillar_player1.png"))
		$BubbleGfx.scale=Vector2(0.08,0.08)
	elif type == 3:
		$BubbleGfx.set_texture(load("res://resources/pillar_player2.png"))
		$BubbleGfx.scale=Vector2(0.08,0.08)
	elif type == 2:
		$BubbleGfx.set_texture(load("res://resources/bubble03b.png"))
		$BubbleGfx.scale=Vector2(0.2,0.2)
	elif type == 4:
		$BubbleGfx.set_texture(load("res://resources/bubble03b_2.png"))
		$BubbleGfx.scale=Vector2(0.2,0.2)
	elif type == 0:
		$BubbleGfx.set_texture(null)
		$Button.visible=true
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	board=get_tree().get_root().get_node("root/Board")
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$RichTextLabel.text="[center]"+str(tileType)+"[/center]"


func _on_button_button_down() -> void:

	if(board.turnOrder[board.currentTurn]!=board.Players.AUTOMATA):
		#print(tileType)
		setTileType(board.turnOrder[board.currentTurn])
		board.changeTurn()
		appear()
	pass # Replace with function body.

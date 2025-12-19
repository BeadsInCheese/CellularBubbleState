extends TextureButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	texture_normal=load(textures[tileType])

var tileType=0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

var textures=["res://resources/GFX/Bubble icons/bubble_player1.png","res://resources/GFX/towers/pillar_player1.png","res://resources/GFX/Bubble icons/bubble03b.png","res://resources/GFX/towers/pillar_player2.png","res://resources/GFX/Bubble icons/bubble03b_2.png"]
func _on_pressed() -> void:
	tileType=(tileType+1)%5
	texture_normal=load(textures[tileType])

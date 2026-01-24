extends TextureButton

@export var output:bool
# Called when the node enters the scene tree for the first time.
var tileType=-1
func _ready() -> void:
	
	if output:
		tileType=0
	texture_normal=load(textures[tileType+1])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

var textures=["res://resources/GFX/Bubble icons/bubble02b_2.png","res://rulesetMaker/ruleset icons/empty icon.png","res://resources/GFX/towers/pillar_player1.png","res://rulesetMaker/ruleset icons/bubble 1 icon.png","res://resources/GFX/towers/pillar_player2.png","res://rulesetMaker/ruleset icons/bubble 2 icon.png"]
func updateUI():
	texture_normal=load(textures[tileType+1])
	
func _on_pressed() -> void:
	if output:
		tileType=(tileType+1)%5
	else:
		tileType=(tileType+2)%6-1
	
	updateUI()

extends TextureButton
@export var output:bool
# Called when the node enters the scene tree for the first time.
var tileType=-1
var audio:AudioStreamPlayer
func _ready() -> void:
	audio = get_tree().root.get_node("RuleEdit/sfx")
	if output:
		tileType=0
	texture_normal=load(textures[tileType+1])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

var textures=["res://rulesetMaker/ruleset icons/any.png","res://rulesetMaker/ruleset icons/empty icon.png","res://rulesetMaker/ruleset icons/tower1.png","res://rulesetMaker/ruleset icons/bubble 1 icon.png","res://rulesetMaker/ruleset icons/tower2.png","res://rulesetMaker/ruleset icons/bubble 2 icon.png"]
func updateUI():
	texture_normal=load(textures[tileType+1])
	
func _on_pressed() -> void:
	AudioManager.play_sound(AudioManager.Sounds.BUTTONV1)
	if output:
		tileType=(tileType+1)%5
	else:
		tileType=(tileType+2)%6-1
	
	updateUI()

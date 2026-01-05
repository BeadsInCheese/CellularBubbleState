extends CanvasLayer

class_name ProgressionManager
# Called when the node enters the scene tree for the first time.
static var achievements={}
@export 
var data:Array[enemyResource]
@export
var after_stage_dialogue:Array[String]
static var fightsWon=0
static var current_fight=0
func adventure_dialogue_decode(i:int):
	await $DialogueBox.playDialogue(data[i].dialogue)
func get_bot(i:int):
	return data[i].bot_index
static func set_progress(val):
	if(val<=fightsWon):
		return
	fightsWon=val
	save_progress()

static func save_progress():
	var config = ConfigFile.new()
	config.set_value("progress", "progress", fightsWon)
	config.save("user://progress.cfg")
static func load_progress():
	var config = ConfigFile.new()
	var err = config.load("user://progress.cfg")
	if err != OK:
		return
	for player in config.get_sections():
		fightsWon = config.get_value(player, "progress")

func _ready() -> void:
	Board.tutorial=false
	Board.adventure=true
	Board.mp=false
	var levels=$levels.get_children()
	load_progress()
	for i in len(levels):
		if i<=fightsWon:
			levels[i].get_child(0).disabled=false
		else:
			levels[i].get_child(0).disabled=true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func fight_button_pressed(opponent) -> void:
	await adventure_dialogue_decode(opponent)
	Settings.P1Index=0
	Settings.P2Index=get_bot(opponent)
	current_fight=opponent
	SceneNavigation.go_to_game()

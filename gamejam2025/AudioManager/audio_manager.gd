extends Node

# Called when the node enters the scene tree for the first time.
enum Sounds{
	BUTTONV1,BUTTONV2
}
enum Musics{
	MAINMENU
}
var sound_dic={Sounds.BUTTONV1:preload("res://rulesetMaker/sfx/sounds/button1.ogg")}
var music_dic={Musics.MAINMENU:preload("res://sunrise_over_water.mp3")}
func play_sound(sound:Sounds):
	$sfx.stream=sound_dic[sound]
	$sfx.play()
func play_music(sound:Musics):
	$music.stream=music_dic[sound]
	$music.play()
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

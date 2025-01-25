extends Node

var sfxVolume:float=80
var musicVolume:float=80
var masterVolume:float=80
func setSFX(volume):
	sfxVolume=volume
	var sfx_index= AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_db(sfx_index, sfxVolume-80)
	
func setMusic(volume):
	musicVolume=volume
	var Music_index= AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(Music_index, musicVolume-80)
	
func setMaster(volume):
	masterVolume=volume
	var Master_index= AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(Master_index, masterVolume-80)

func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

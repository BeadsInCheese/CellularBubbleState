extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Master.value=Settings.masterVolume
	$SFX.value=Settings.sfxVolume
	$Music.value=Settings.musicVolume


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_master_value_changed(value: float) -> void:
	Settings.setMaster(value)


func _on_sfx_value_changed(value: float) -> void:
	Settings.setSFX(value)


func _on_music_value_changed(value: float) -> void:
	Settings.setMusic(value)


func _on_button_button_down() -> void:
	SceneNavigation._on_MainMenuPressed()


func _on_fxaa_toggled(toggled_on: bool) -> void:
	ProjectSettings.set_setting("rendering/quality/fxaa", 2)  # 2x MSAA
	ProjectSettings.save()

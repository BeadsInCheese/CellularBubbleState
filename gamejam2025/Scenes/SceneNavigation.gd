extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _onLocalMPSelected() -> void:
	get_tree().change_scene_to_packed(load("res://MainGame.tscn"))
	

func _on_MainMenuPressed() -> void:
	get_tree().change_scene_to_packed(load("res://Scenes/MainMenu.tscn"))


func _on_SettingsPressed() -> void:
	get_tree().change_scene_to_packed(load("res://Scenes/SettingsMenu.tscn"))

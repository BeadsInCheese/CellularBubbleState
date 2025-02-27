extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _onLocalMPSelected() -> void:
	SceneNavigation._onLocalMPSelected()
	
func _on_MainMenuPressed() -> void:
	SceneNavigation._on_MainMenuPressed()
		
func goToMultiplayerSelection():
	SceneNavigation.goToMultiplayerSelection()

func goToWait():
	SceneNavigation.goToWait()
		
func _on_SettingsPressed() -> void:
	SceneNavigation._on_SettingsPressed()
		
func _on_PlayerMenuPressed() -> void:
	SceneNavigation._on_PlayerMenuPressed()



func _on_MPbutton_3_button_down() -> void:
	SceneNavigation.goToMultiplayerSelection()

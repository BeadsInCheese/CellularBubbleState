extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _onLocalMPSelected() -> void:
	goToScene("res://MainGame.tscn")

func _on_MainMenuPressed() -> void:
	goToScene("res://Scenes/MainMenu.tscn")
		
func goToMultiplayerSelection():
	goToScene("res://Scenes/MPLobby/MultiplayerLobby.tscn")
		
func goToWait():
	goToScene("res://Scenes/MPLobby/LobbyWaitForClient.tscn")

func _on_SettingsPressed() -> void:
	goToScene("res://Scenes/SettingsMenu.tscn")
		
func _on_PlayerMenuPressed() -> void:
	goToScene("res://PlayerSelect.tscn")


func goToScene(scene: String):
	# Wait hide animation
	for i in range(51):
		RenderingServer.global_shader_parameter_set("tt",i*0.02)
		if(get_tree()!=null):
			await get_tree().process_frame
	
	# Change scene
	if(get_tree()!=null):
		await get_tree().process_frame
		get_tree().change_scene_to_packed(load(scene))

func showall():
	for i in range(51):
		RenderingServer.global_shader_parameter_set("tt",1-i*0.02)
		if(get_tree()!=null):
			await get_tree().process_frame


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("Quit"):
		get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
		get_tree().quit()
		
	if Input.is_action_just_pressed("Mute"):
		print(Settings.masterVolume)
		if Settings.masterVolume == 0:
			Settings.setMaster(80)
		else:
			Settings.setMaster(0)

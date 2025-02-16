extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _onLocalMPSelected() -> void:
	await hideall()
	if(get_tree()!=null):
		await get_tree().process_frame
		get_tree().change_scene_to_packed(load("res://MainGame.tscn"))
	

func _on_MainMenuPressed() -> void:
	await hideall()
	if(get_tree()!=null):
		await get_tree().process_frame
		get_tree().change_scene_to_packed(load("res://Scenes/MainMenu.tscn"))
func goToMultiplayerSelection():
	await hideall()
	if(get_tree()!=null):
		await get_tree().process_frame
		get_tree().change_scene_to_packed(load("res://Scenes/MPLobby/MultiplayerLobby.tscn"))	
func goToWait():
	await hideall()
	if(get_tree()!=null):
		await get_tree().process_frame
		get_tree().change_scene_to_packed(load("res://Scenes/MPLobby/LobbyWaitForClient.tscn"))	
func _on_SettingsPressed() -> void:
	await hideall()
	if(get_tree()!=null):
		await get_tree().process_frame
		get_tree().change_scene_to_packed(load("res://Scenes/SettingsMenu.tscn"))
func _on_PlayerMenuPressed() -> void:
	await hideall()
	if(get_tree()!=null):
		await get_tree().process_frame
		get_tree().change_scene_to_packed(load("res://PlayerSelect.tscn"))
func hideall():
	for i in range(51):
		RenderingServer.global_shader_parameter_set("tt",i*0.02)
		if(get_tree()!=null):
			await get_tree().process_frame
func showall():
	for i in range(51):
		RenderingServer.global_shader_parameter_set("tt",1-i*0.02)
		if(get_tree()!=null):
			await get_tree().process_frame


func _on_MPbutton_3_button_down() -> void:
	SceneNavigation.goToMultiplayerSelection()

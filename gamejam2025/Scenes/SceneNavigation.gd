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
func _on_MapPressed()-> void:
	goToScene("res://resources/AdventureMode/Scenes/Map.tscn")
func _on_RulesetCreatorPressed():
	goToScene("res://rulesetMaker/RuleEdit.tscn")
var loading=false
func goToScene(scene: String):
	# Wait hide animation
	if loading:
		return
	loading=true
	for i in range(51):
		RenderingServer.global_shader_parameter_set("tt",i*0.02)
		if(get_tree()!=null):
			await get_tree().process_frame
	
	# Change scene
	if(get_tree()!=null):
		await get_tree().process_frame
		get_tree().change_scene_to_packed(load(scene))
	loading=false
func showall():
	for i in range(51):
		RenderingServer.global_shader_parameter_set("tt",1-i*0.02)
		if(get_tree()!=null):
			await get_tree().process_frame


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Quit"):
		get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
		get_tree().quit()

	if event.is_action_pressed("Mute"):
		if Settings.masterVolume == 0:
			Settings.setMaster(80)
		else:
			Settings.setMaster(0)

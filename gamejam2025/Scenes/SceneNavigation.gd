extends Node2D


func go_to_game(push_as_child = false) -> void:
	_go_to_scene("res://MainGame.tscn", push_as_child)

func go_to_main_menu() -> void:
	_go_to_scene("res://Scenes/MainMenu.tscn")

func go_to_multiplayer_selection():
	_go_to_scene("res://Scenes/MPLobby/MultiplayerLobby.tscn")
		
func go_to_multiplayer_lobby():
	_go_to_scene("res://Scenes/MPLobby/LobbyWaitForClient.tscn")

func go_to_settings() -> void:
	_go_to_scene("res://Scenes/SettingsMenu.tscn")
		
func go_to_player_selection() -> void:
	_go_to_scene("res://PlayerSelect.tscn")

func go_to_map()-> void:
	_go_to_scene("res://resources/AdventureMode/Scenes/Map.tscn")

func go_to_ruleset_editor():
	_go_to_scene("res://rulesetMaker/RuleEdit.tscn")

var loading = false
var pushed_scene = null

func _go_to_scene(scene: String, push_as_child = false):
	if loading:
		return

	if pushed_scene != null:
		pushed_scene.queue_free()
		pushed_scene = null

	# Wait hide animation
	loading=true
	for i in range(51):
		RenderingServer.global_shader_parameter_set("tt",i*0.02)
		if(get_tree()!=null):
			await get_tree().process_frame
	
	# Change scene
	if(get_tree()!=null):
		await get_tree().process_frame
		if push_as_child:
			pushed_scene = load(scene).instantiate()
			get_tree().root.add_child(pushed_scene)
		else:
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

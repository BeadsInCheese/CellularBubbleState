extends TextEdit

func _on_text_changed() -> void:
	if(len(text)>5):
		text=text.substr(0,5)
		
	text=text.to_upper()
	set_caret_column(len(text))

func _on_host_button_pressed() -> void:
	var characterList="ABCDEFGHIJKLMNOPQRSTUVXYZ1234567890"
	var key=""
	for i in range(5):
		key+=characterList[randi_range(0,len(characterList)-1)]

	start_game(key)


func _on_join_button_pressed() -> void:
	var key=text.to_upper()
	if len(key) < 5:
		return
	
	start_game(key)


func start_game(key: String):
	Board.tutorial = false
	Settings.MPKey=key
	SceneNavigation.go_to_multiplayer_lobby()


func _on_back_button_pressed() -> void:
	SceneNavigation.go_to_main_menu()
	
func _input(event):
	if event.is_action_pressed("ui_text_submit"):
		_on_join_button_pressed()

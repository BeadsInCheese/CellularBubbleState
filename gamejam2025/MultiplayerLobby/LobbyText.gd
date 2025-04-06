extends TextEdit


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_text_changed() -> void:
	if(len(text)>5):
		text=text.substr(0,5)
		
	text=text.to_upper()
	set_caret_column(len(text))

var rng = RandomNumberGenerator.new()
func _on_host_button_pressed() -> void:
	var characterList="ABCDEFGHIJKLMNOPQRSTUVXYZ1234567890"
	var key=""
	for i in range(5):
		key+=characterList[rng.randi_range(0,len(characterList)-1)]

	print(key)
	Settings.MPKey=key
	SceneNavigation.goToWait()

func _on_back_button_pressed() -> void:
	SceneNavigation._on_MainMenuPressed()
	

func _on_join_button_pressed() -> void:
	var key=text.to_upper()
	if len(key) < 5:
		return

	print(key)
	Settings.MPKey=key
	SceneNavigation.goToWait()

func _input(event):
	if event.is_action_pressed("ui_text_submit"):
		_on_join_button_pressed()

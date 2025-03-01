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

var rng = RandomNumberGenerator.new()
func _on_host_button_pressed() -> void:
	var charaterList="ABCDEFGHIJKLMNOPQRSTUVXYZ1234567890"
	var key=""
	for i in range(5):
		key+=charaterList[rng.randi_range(0,len(charaterList)-1)]
	print(key)
	Settings.MPKey=key
	SceneNavigation.goToWait()

func _on_back_button_pressed() -> void:
	SceneNavigation._on_MainMenuPressed()
	

func _on_join_button_pressed() -> void:
	var key=text.to_upper()
	while len(key)<5:
		key+="0"
	print(key)
	Settings.MPKey=key
	SceneNavigation.goToWait()

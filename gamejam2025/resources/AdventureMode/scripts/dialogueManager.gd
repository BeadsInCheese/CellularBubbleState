extends Panel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	playDialogue(["Boss@Whats upssssssssssssssssssssssssssssssssssssssssssssssssssss","Me@Not much how about youaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa","Boss@not muchbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb "])


# Called every frame. 'delta' is the elapsed time since the previous frame.
var advance=false
func _process(delta: float) -> void:
	if(Input.is_action_just_pressed("ui_accept")):
		advance=true
func inputProgress():
	while is_instance_valid(self):
		if(Input.is_action_just_pressed("ui_accept")):
			await get_tree().process_frame
			return
		await get_tree().process_frame
func waitOrWrite(txt:String):
	$dialogue.text=""
	advance=false
	$sfx.play()
	for i in txt:
		if(!advance):
			await get_tree().create_timer(0.04).timeout
		$dialogue.text+=i
	$sfx.stop()
	await get_tree().process_frame
func playDialogue(dialogue:Array[String]):
	visible=true
	for i in dialogue:
		var parts=i.split("@")
		$Panel/Header.text="[center]"+parts[0]+"[center]"
		if len(parts)>1:
			await waitOrWrite(parts[1])
		await inputProgress()
	visible=false

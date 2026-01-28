extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_pressed() -> void:
	$FileDialog.visible=true


func _on_file_dialog_file_selected(path: String) -> void:
	var rules=ruleSet.new()
	rules.load_from_file(path)
	AutomataAgent.ruleset=rules.getAsArray()
	AutomataAgent.ruleset_name=rules.name
	$rulesetName.text="loaded ruleset: "+rules.name

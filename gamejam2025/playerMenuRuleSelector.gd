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
	var file = FileAccess.open(path, FileAccess.READ)
	rules.deserialize(file.get_as_text())
	file.close()
	AutomataAgent.ruleset=rules.getAsArray()
	AutomataAgent.loadCustomRuleset=true

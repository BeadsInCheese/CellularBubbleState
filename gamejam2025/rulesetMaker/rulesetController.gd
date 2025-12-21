extends CanvasLayer

var ruleTemplate=preload("res://rulesetMaker/rule.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$MenuButton.get_popup().id_pressed.connect(_on_menu_button_pressed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_menu_button_pressed(id) -> void:
	if(id==0):
		$MatrixBase.sizex=3
		$MatrixBase.sizey=3
		$MenuButton.text="3x3"
	else:
		$MatrixBase.sizex=5
		$MatrixBase.sizey=5
		$MenuButton.text="5x5"
	$MatrixBase.updateUI()

func addRule(ruleName,pattern,result):
	var rule=ruleTemplate.instantiate()
	rule.get_node("rulename").text=ruleName+str(pattern)+"-->"+str(result)
	rule.ruleName=ruleName
	rule.result=result
	rule.rule=pattern
	
	$ListBg/ScrollContainer/VBoxContainer.add_child(rule)
func _on_add_rule_button_pressed() -> void:
	var rule=ruleTemplate.instantiate()
	var mat=$MatrixBase.getMatrix()
	rule.get_node("rulename").text=$LineEdit.text+str(mat)+"-->"+str($resultButton.tileType)
	rule.ruleName=$LineEdit.text
	rule.result=$resultButton.tileType
	rule.rule=mat
	$ListBg/ScrollContainer/VBoxContainer.add_child(rule)


func _on_load_button_pressed() -> void:
	$load.visible=true


func _on_save_button_pressed() -> void:
	$save.visible=true


func _on_save_file_selected(path: String) -> void:
	var ruleset:ruleSet=ruleSet.new()
	for i in $ListBg/ScrollContainer/VBoxContainer.get_children():
		ruleset.addRule(i.ruleName,i.rule,i.result)
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(ruleset.serialize())
	file.close()


func _on_load_file_selected(path: String) -> void:
	var file = FileAccess.open(path, FileAccess.READ)
	var ruleset:ruleSet=ruleSet.new()
	ruleset.deserialize(file.get_as_text())
	file.close()
	for i in $ListBg/ScrollContainer/VBoxContainer.get_children():
		i.queue_free()
	for i in ruleset.rules.keys():
		addRule(i,ruleset.rules[i].pattern,ruleset.rules[i].result)


func _on_exit_pressed() -> void:
	SceneNavigation._on_PlayerMenuPressed()

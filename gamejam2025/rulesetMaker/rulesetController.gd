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

func entryExists(nodeName:String):
	for child in $ListBg/ScrollContainer/VBoxContainer.get_children():
		if(child.name==nodeName):
			return true
	return false
func UImodifyRule():
	$MatrixBase.setMatrix(selected.rule)
	$resultButton.tileType=selected.result
	$resultButton.updateUI()
	$LineEdit.text=selected.name
func setRule(ruleName,pattern,result):
	for child in $ListBg/ScrollContainer/VBoxContainer.get_children():
		if(child.name==ruleName):
			child.rule=pattern
			child.result=result
			child.get_node("rulename").text=ruleName+str(pattern)+"-->"+str(result)
func getHovered():
	for i in $ListBg/ScrollContainer/VBoxContainer.get_children():
		if(i.hovered):
			return i
var selected
var pressed:bool=false

func _input(event: InputEvent) -> void:
	if(event.is_action_pressed("mouse_left")):
		pressed=true
		var hoveredObject=getHovered()
		if(hoveredObject!=null):
			selected=hoveredObject
			UImodifyRule()
	if(event.is_action_released("mouse_left")):
		if( selected!=null):
			selected=null
		var pressed:bool=false
	if(event is InputEventMouseMotion and pressed and selected!=null):
		recalculatePosition()
func recalculatePosition():
	var container=$ListBg/ScrollContainer/VBoxContainer
	for child in container.get_children():
		if(child.global_position.y<get_viewport().get_mouse_position().y):
			if(child.get_index()>selected.get_index()):
				container.move_child(selected,child.get_index())
				return
		if(child.global_position.y+(child.size.y)>get_viewport().get_mouse_position().y):
			if(child.get_index()<selected.get_index()):
				container.move_child(selected,child.get_index())
				return

func addRule(ruleName,pattern,result):
	if(entryExists(ruleName)):
		setRule(ruleName,pattern,result)
		return
	var rule=ruleTemplate.instantiate()
	rule.get_node("rulename").text=ruleName+str(pattern)+"-->"+str(result)
	rule.ruleName=ruleName
	rule.result=result
	rule.rule=pattern
	$ListBg/ScrollContainer/VBoxContainer.add_child(rule)
	rule.name=ruleName
func _on_add_rule_button_pressed() -> void:
	var mat=$MatrixBase.getMatrix()
	var Rulename=$LineEdit.text
	if(Rulename!=""):
		addRule(Rulename,mat,$resultButton.tileType)
		$LineEdit.text=""


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
	SceneNavigation.go_to_player_selection()


func _on_line_edit_text_submitted(new_text: String) -> void:
	_on_add_rule_button_pressed()


func _on_matrix_base_size_changed(sizex: Variant, sizey: Variant) -> void:
	$MenuButton.text=str(sizex)+"x"+str(sizey)

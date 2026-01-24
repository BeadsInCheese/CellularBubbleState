extends Control

var UITile:PackedScene=preload("res://rulesetMaker/rulesetTile.tscn")
# Called when the node enters the scene tree for the first time.
var sizex=3
var sizey=3
func _ready() -> void:
	updateUI()
	print(getMatrix())
signal sizeChanged(sizex,sizey)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func getMatrix():
	var matrix=[]
	for i in $VBoxContainer.get_children():
		for j in i.get_children():
			matrix.append(j.tileType)
	return matrix
func __setMatrix(mat):
	await get_tree().process_frame
	var index=0
	for i in $VBoxContainer.get_children():
		for j in i.get_children():
			
			j.tileType=mat[index]
			j.updateUI()
			index+=1
func setMatrix(mat):
	if(mat.size()==sizey*sizex):
		__setMatrix(mat)
	else:
		sizex=sqrt(mat.size())
		sizey=sqrt(mat.size())
		updateUI()
		sizeChanged.emit(sizex,sizey)
		__setMatrix(mat)
func updateUI():
	for node in $VBoxContainer.get_children():
		node.free()
	for i in sizey:
		var hBox=HBoxContainer.new()
		hBox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hBox.size_flags_vertical = Control.SIZE_EXPAND_FILL

		$VBoxContainer.add_child(hBox)
		for j in sizex:
			var tile=UITile.instantiate()
			tile.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			tile.size_flags_vertical = Control.SIZE_EXPAND_FILL
			
			hBox.add_child(tile)

extends Control

var UITile:PackedScene=preload("res://rulesetMaker/rulesetTile.tscn")
# Called when the node enters the scene tree for the first time.
var sizex=3
var sizey=3
func _ready() -> void:
	updateUI()
	print(getMatrix())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func getMatrix():
	var matrix=[]
	for i in $VBoxContainer.get_children():
		for j in i.get_children():
			matrix.append(j.tileType)
	return matrix
func updateUI():
	for node in $VBoxContainer.get_children():
		node.queue_free()
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

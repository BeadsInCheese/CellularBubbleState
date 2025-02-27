extends Window
class_name Loader

var listItem = preload("res://LoadItem.tscn")
static var n = 0
var item_list = []

#always_on_top = true
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var titleArray =  DataUtility.get_saves()
	var noSaves = len(titleArray)
	
	for i in range(noSaves):
		var x : LoadItem = listItem.instantiate()
		x.n = i
		x.text = titleArray[i]
		$ScrollContainer/List1.add_child(x)
		item_list.append(x)
		
	move_to_center() 
	move_to_foreground()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_close_requested() -> void:
	hide()

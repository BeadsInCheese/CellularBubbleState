extends Panel
class_name Console

# Called when the node enters the scene tree for the first time.
static var instance:Console=null
func _ready() -> void:
	if(instance!=null):
		instance.queue_free()
	instance=self
func _exit_tree() -> void:
	instance=null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func printToConsole(author:String,msg:String):
	$log.text+=author+": "+msg+"\n"
func systemPrintToConsole(msg:String):
	printToConsole("System",msg)

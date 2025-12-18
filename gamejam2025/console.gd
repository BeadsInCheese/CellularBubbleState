extends Panel
class_name Console

# Called when the node enters the scene tree for the first time.
static var instance:Console=null
@export
var consoleLog:TextEdit
@export
var consoleInput:LineEdit

func _ready() -> void:
	if(instance!=null):
		instance.queue_free()
	instance=self
func _exit_tree() -> void:
	instance=null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
var lines=0
func write(author:String,msg:String,end:String="\n"):
	var result=author+ ("" if author=="" else ": ")+msg+end
	lines+=result.count("\n")
	consoleLog.text+=result
	consoleLog.scroll_vertical=lines

func systemWrite(msg:String):
	write("System",msg)
	
func commandProcessor(cmd:String):
	var args=cmd.split(" ")
	if(args[0]=="time"):
		systemWrite(Time.get_datetime_string_from_system())
	if(args[0]=="help"):
		systemWrite("commands:\n/time gets time\n/help get information about available commands")
func _on_input_text_submitted(new_text: String) -> void:
	if(len(new_text)==0):
		return
	write("Player",new_text)
	consoleInput.text=""

	if(new_text[0]=="/"):
		commandProcessor(new_text.substr(1))

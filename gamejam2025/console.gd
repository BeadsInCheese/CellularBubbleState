extends Panel
class_name Console

static var instance: Console = null

signal messageWritten(author,msg,end)

@export
var consoleLog: TextEdit
@export
var consoleInput: LineEdit

func _ready() -> void:
	if(instance!=null):
		instance.queue_free()
	instance=self

func _exit_tree() -> void:
	instance=null

var lines=0

func _write(author:String,msg:String,end:String="\n"):
	var result=author+ ("" if author=="" else ": ")+msg+end
	lines+=result.count("\n")
	consoleLog.text+=result
	consoleLog.scroll_vertical=lines
	messageWritten.emit(author,msg,end)
static func get_log()->String:
	if(instance!=null):
		return instance.consoleLog.text
	else:
		return ""

func _systemWrite(msg:String):
	write("System",msg)
	
func _commandProcessor(cmd:String):
	var args=cmd.split(" ")
	if(args[0]=="time"):
		_systemWrite(Time.get_datetime_string_from_system())
	if(args[0]=="help"):
		_systemWrite("commands:\n/time gets time\n/help get information about available commands")

func _on_input_text_submitted(new_text: String) -> void:
	if(len(new_text)==0):
		return

	_write("Player", new_text)
	consoleInput.text=""

	if(new_text[0]=="/"):
		_commandProcessor(new_text.substr(1))
	
	if NetCode.local_opponent_id != 0:
		NetCode.write_to_console.rpc_id(NetCode.local_opponent_id, "Opponent", new_text)

static func write(author:String,msg:String,end:String="\n"):
	if(instance==null):
		return
	instance._write(author,msg,end)

static func systemWrite(msg:String):
	write("System",msg)

extends Node2D
class_name NetCode
var serverIP="127.0.0.1"
static var client
var connected=false
# Called when the node enters the scene tree for the first time.
var scene = preload("res://MainGame.tscn")
func sendkey(message:String) -> bool:
	print("sending data...")
	client.put_data(message.to_utf8_buffer())
	print("Sent: ", message)
	return true
	print("connection lost")
	return false
func send(x:float,v:int) -> bool:
	print("sending data...")

	client.put_32(x)
	client.put_32(v)
	print("Sent integers: ", x, ", ", v)
	return true
	print("connection lost")
	return false
func _blocking_read():
	while connected:
		if client.get_available_bytes() >= 4:
			print("message")
			client.poll()
			var x=client.get_32()
			print("Received data: ", x)
			return x
		else:
			# Sleep for a short duration to avoid busy-waiting
			await get_tree().process_frame
func connect_to_server(host: String) -> void:
	var err = await client.connect_to_host(host, 1256)
	while  connected==false:
		await get_tree().process_frame
	if err == OK:

		print("Connected to server")
	else:
		print("Failed to connect to server")
func getServerIp()->void:
	var config = ConfigFile.new()
	var err = config.load("res://config/INI_Settings.cfg")
	if err == OK: 
		var ip=config.get_value("MULTIPLAYER","SERVER_IP","127.0.0.1")
		print("loaded IP: "+ip+" fron config")
		serverIP=ip
func _ready() -> void:
	getServerIp()
	client=StreamPeerTCP.new()
	await connect_to_server(serverIP)
	print(client.get_status())
	sendkey(Settings.MPKey)
	var status=await  _blocking_read()
	
	var game=scene.instantiate()
	get_tree().root.add_child(game)
	_send_keep_alive()
	pass # Replace with function body.

func _send_keep_alive():
	var packet = 9000
	client.put_32(packet)
	await get_tree().create_timer(5.0).timeout  # Send keep-alive every 5 seconds
	_send_keep_alive()
# Called every frame. 'delta' is the elapsed time since the previous frame.
var _status=-1
signal _connected
signal _error
signal _disconnected
func _process(delta: float) -> void:
	var new_status: int = client.get_status()
	client.poll()
	if new_status != _status:
		_status = new_status
		match _status:
			client.STATUS_NONE:
				print("Disconnected from host.")
				emit_signal("_disconnected")
			client.STATUS_CONNECTING:
				print("Connecting to host.")
			client.STATUS_CONNECTED:
				print("Connected to host.")
				emit_signal("_connected")
				connected = true
			client.STATUS_ERROR:
				print("Error with socket stream.")
				emit_signal("_error")
func _exit_tree() -> void:
	client.disconnect_from_host()
	pass

func _on_button_3_pressed() -> void:
	SceneNavigation.goToMultiplayerSelection()

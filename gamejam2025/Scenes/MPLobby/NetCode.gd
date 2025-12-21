extends Node2D
class_name NetCode

static var client: StreamPeerTCP = null

var connected = false
var _status = -1

signal _connected
signal _error
signal _disconnected

var use_localhost = true

# Called when the node enters the scene tree for the first time.
var scene = preload("res://MainGame.tscn")

var game = null

func sendkey(message:String) -> bool:
	print("sending data...")
	
	client.put_data(message.to_utf8_buffer())
	
	print("Sent: ", message)
	return true
	
func send(x:float,v:int) -> bool:
	print("sending data...")

	client.put_32(x)
	client.put_32(v)
	
	print("Sent integers: ", x, ", ", v)
	return true

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
	client = StreamPeerTCP.new()
	
	var err = await client.connect_to_host(host, 25565)
	while not connected:
		await get_tree().process_frame
	
	if err == OK:
		print("Connected to server")
	else:
		print("Failed to connect to server")
		_on_back_button_pressed()

func get_server_ip() -> String:
	var config = ConfigFile.new()
	var load_status = config.load("res://config/INI_Settings.cfg")
	var localhost = "127.0.0.1"

	if load_status == OK and not use_localhost: 
		var ip=config.get_value("MULTIPLAYER", "SERVER_IP", localhost)
		print("loaded IP: "+ip+" fron config")
		return ip

	return localhost

func _ready() -> void:
	await connect_to_server(get_server_ip())
	
	print(client.get_status())
	sendkey(Settings.MPKey)
	var status = await _blocking_read()
	
	game = scene.instantiate()
	get_tree().root.add_child(game)

func _send_keep_alive():
	var packet = 9000
	client.put_32(packet)
	await get_tree().create_timer(5.0).timeout  # Send keep-alive every 5 seconds
	_send_keep_alive()

func _process(delta: float) -> void:
	var new_status: int = client.get_status()
	client.poll()
	if new_status != _status:
		_status = new_status

		match new_status:
			client.STATUS_NONE:
				print("Disconnected from host.")
				_disconnected.emit()
			client.STATUS_CONNECTING:
				print("Connecting to host.")
			client.STATUS_CONNECTED:
				print("Connected to host.")
				_connected.emit()
				connected = true
			client.STATUS_ERROR:
				print("Error with socket stream.")
				_error.emit()
				connected=false

func _exit_tree() -> void:
	connected=false
	client.disconnect_from_host()

	if(game!=null):
		game.queue_free()

func _on_back_button_pressed() -> void:
	if(game!=null):
		game.queue_free()

	SceneNavigation.goToMultiplayerSelection()

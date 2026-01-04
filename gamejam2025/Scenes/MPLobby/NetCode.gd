extends Node2D
class_name NetCode

#static var client: StreamPeerTCP = null
#
#var connected = false
#var _status = -1
#
#signal _connected
#signal _error
#signal _disconnected

#var scene = preload("res://MainGame.tscn")
#var game = null

#
#func sendkey(message:String) -> void:
	#client.put_data(message.to_utf8_buffer())
	#print("Sent: ", message)
#
#func wait_until_game_start():
	#while connected:
		#if client.get_available_bytes() >= 4:
			#client.poll()
			#client.get_32()
			#return
		#else:
			## Sleep for a short duration to avoid busy-waiting
			#await get_tree().process_frame
#
#func connect_to_server() -> void:
	#client = StreamPeerTCP.new()
	#
	#var err = await client.connect_to_host(get_server_ip(), Server.PORT)
	#while not connected:
		#await get_tree().process_frame
	#
	#if err == OK:
		#print("Connected to server")
	#else:
		#print("Failed to connect to server")
		#_on_back_button_pressed()

static func get_server_ip() -> String:
	var config = ConfigFile.new()
	var localhost = "127.0.0.1"

	var load_status = config.load("res://config/INI_Settings.cfg")

	if load_status == OK and false: 
		var ip=config.get_value("MULTIPLAYER", "SERVER_IP", localhost)
		print("loaded IP: " + ip + " from config")
		return ip

	return localhost

func _ready() -> void:
	Server.start_client(get_server_ip())
	
	#await connect_to_server()
	#sendkey(Settings.MPKey)
	#await wait_until_game_start()
	#start_game()


#func _process(delta: float) -> void:
	#var new_status: int = client.get_status()
	#client.poll()
	#if new_status != _status:
		#_status = new_status
#
		#match new_status:
			#client.STATUS_NONE:
				#print("Disconnected from host.")
				#_disconnected.emit()
			#client.STATUS_CONNECTING:
				#print("Connecting to host.")
			#client.STATUS_CONNECTED:
				#print("Connected to host.")
				#_connected.emit()
				#connected = true
			#client.STATUS_ERROR:
				#print("Error with socket stream.")
				#_error.emit()
				#connected=false

#func _exit_tree() -> void:
	#connected=false
	#client.disconnect_from_host()
#
	#if(game!=null):
		#game.queue_free()
#
#func _on_back_button_pressed() -> void:
	#if(game!=null):
		#game.queue_free()
#
	#SceneNavigation.goToMultiplayerSelection()

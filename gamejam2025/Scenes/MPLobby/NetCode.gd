extends Node

var peer: WebSocketMultiplayerPeer

const PORT: int = 25565

var lobbies: Dictionary = {}

signal on_move_confirmed(tile_index: int, tile_type: int)

func start_server() -> void:
	peer = WebSocketMultiplayerPeer.new()
	var error = peer.create_server(PORT)
	if error:
		print("Failed to start server on port ", PORT, ". Error: ", error_string(error))
		return
	
	multiplayer.multiplayer_peer = peer

func start_client() -> void:
	peer = WebSocketMultiplayerPeer.new()
	peer.create_client("ws://" + get_server_ip() + ":" + str(PORT))
	
	multiplayer.multiplayer_peer = peer


func get_server_ip() -> String:
	var config = ConfigFile.new()
	var load_status = config.load("res://config/INI_Settings.cfg")

	if load_status != OK or true:
		return "127.0.0.1"

	return config.get_value("MULTIPLAYER", "SERVER_IP", "127.0.0.1")

@rpc("any_peer", "reliable")
func start_lobby(connecting_id: int, lobby_key: String):
	print("Received key: ", lobby_key)
	
	if lobby_key in lobbies.keys():
		var sides = randi_range(0, 1) == 0
		
		var lobby_players = lobbies[lobby_key]
		lobby_players.append(connecting_id)
		
		start_game.rpc_id(lobby_players[0], sides)
		start_game.rpc_id(lobby_players[1], !sides)
	else:
		lobbies[lobby_key] = [connecting_id]
	pass

@rpc("authority", "reliable")
func start_game(is_player1: bool):
	Settings.MPPlayer1 = is_player1
	SceneNavigation.go_to_game(true)

@rpc("any_peer", "reliable")
func request_move(connecting_id, tile_index, tile_type, lobby_key):
	for id in lobbies[lobby_key]:
		if id != connecting_id:
			confirm_move.rpc_id(id, tile_index, tile_type)

@rpc("authority", "reliable")
func confirm_move(tile_index, tile_type):
	on_move_confirmed.emit(tile_index, tile_type)

func on_peer_connected(id: int):
	if id == 1: # Register lobby when connecting to the server
		start_lobby.rpc_id(id, multiplayer.get_unique_id(), Settings.MPKey)
	
	# peer connection callback not needed after initial connection to server has been established
	multiplayer.peer_connected.disconnect(on_peer_connected)

func _ready() -> void:
	if DisplayServer.get_name() == "headless":
		start_server()
	else:
		multiplayer.peer_connected.connect(on_peer_connected)

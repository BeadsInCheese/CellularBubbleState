extends Node

var peer: WebSocketMultiplayerPeer

const PORT: int = 25565

var lobbies: Dictionary = {}
var players: Dictionary = {}

signal on_move_confirmed(tile_index: int, tile_type: int)

func start_server() -> void:
	peer = WebSocketMultiplayerPeer.new()
	var error = peer.create_server(PORT)
	if error:
		print("Failed to start server on port ", PORT, ". Error: ", error_string(error))
		return
	
	multiplayer.multiplayer_peer = peer

func start_client() -> void:
	if peer == null:
		peer = WebSocketMultiplayerPeer.new()

	peer.create_client("ws://" + get_server_ip() + ":" + str(PORT))
	
	multiplayer.multiplayer_peer = peer

func disconnect_client() -> void:
	peer.disconnect_peer(1)


func get_server_ip() -> String:
	var config = ConfigFile.new()
	var load_status = config.load("res://config/INI_Settings.cfg")

	if load_status != OK or true:
		return "127.0.0.1"

	return config.get_value("MULTIPLAYER", "SERVER_IP", "127.0.0.1")

@rpc("any_peer", "reliable")
func start_lobby(connecting_id: int, lobby_key: String):
	if lobby_key in lobbies:
		var sides = randi_range(0, 1) == 0
		
		var lobby_players = lobbies[lobby_key]
		if len(lobby_players) > 1:
			return # if lobby is full, discard additional players
		
		lobby_players.append(connecting_id)
		
		start_game.rpc_id(lobby_players[0], sides)
		start_game.rpc_id(lobby_players[1], !sides)
	else:
		lobbies[lobby_key] = [connecting_id]
	
	players[connecting_id] = lobby_key

@rpc("authority", "reliable")
func start_game(is_player1: bool):
	Settings.MPPlayer1 = is_player1
	SceneNavigation.go_to_game(true)

@rpc("any_peer", "reliable")
func request_move(connecting_id: int, tile_index: int, tile_type: int, lobby_key: String):
	confirm_move.rpc_id(get_opponent_id(connecting_id, lobby_key), tile_index, tile_type)

func get_opponent_id(id: int, lobby_key: String) -> int:
	for other_id in lobbies[lobby_key]:
		if other_id != id:
			return other_id
	return 1

@rpc("authority", "reliable")
func confirm_move(tile_index: int, tile_type: int):
	on_move_confirmed.emit(tile_index, tile_type)

@rpc("authority", "reliable")
func write_to_console(message: String):
	Console.write("Server", message)

func on_peer_connected(id: int):
	if id == 1: # Register lobby when connecting to the server
		start_lobby.rpc_id(id, multiplayer.get_unique_id(), Settings.MPKey)

func on_peer_disconnected(id: int):
	if not id in players: # if player connection was invalid, do not destroy lobby
		return
	
	var lobby_key = players[id]
	write_to_console.rpc_id(get_opponent_id(id, lobby_key), "Client " + str(id) + " disconnected!!!")
	
	lobbies.erase(lobby_key)
	players.erase(id)

func _ready() -> void:
	if DisplayServer.get_name() == "headless":
		start_server()
		
		multiplayer.peer_disconnected.connect(on_peer_disconnected)
	else:
		multiplayer.peer_connected.connect(on_peer_connected)

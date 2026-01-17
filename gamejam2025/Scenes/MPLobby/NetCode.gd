extends Node

var peer: WebSocketMultiplayerPeer

const PORT: int = 25565

class PlayerInfo:
	var lobby_key: String
	var opponent_id: int
	
	func _init(lobby_key: String, opponent_id: int) -> void:
		self.lobby_key = lobby_key
		self.opponent_id = opponent_id

var lobbies: Dictionary = {} # key: lobby_key, value: Array<int> (player_id array)
var players: Dictionary = {} # key: player_id, value: PlayerInfo

var local_opponent_id: int = 0 # id of the current opponent. 0 if not connected to a game

signal on_move_confirmed(tile_index: int, tile_type: int)

func start_server() -> void:
	peer = WebSocketMultiplayerPeer.new()
	var error = peer.create_server(PORT)
	if error:
		print("Failed to start server on port ", PORT, ". Error: ", error_string(error))
		return
	
	multiplayer.multiplayer_peer = peer

func connect_client() -> void:
	if peer == null:
		peer = WebSocketMultiplayerPeer.new()

	peer.create_client("ws://" + get_server_ip() + ":" + str(PORT))
	
	multiplayer.multiplayer_peer = peer

func disconnect_client() -> void:
	if peer != null:
		peer.close()
	
	local_opponent_id = 0


func get_server_ip() -> String:
	var config = ConfigFile.new()
	var load_status = config.load("res://config/INI_Settings.cfg")

	if load_status != OK or true:
		return "127.0.0.1"

	return config.get_value("MULTIPLAYER", "SERVER_IP", "127.0.0.1")

@rpc("any_peer", "reliable")
func start_lobby(lobby_key: String):
	var connecting_id = multiplayer.get_remote_sender_id()
	
	if lobby_key in lobbies:
		var lobby_players: Array = lobbies[lobby_key]
		if len(lobby_players) != 1:
			return # if lobby is full, discard additional players

		var opponent_id = lobby_players[0]
		
		players[connecting_id] = PlayerInfo.new(lobby_key, opponent_id)
		players[opponent_id] = PlayerInfo.new(lobby_key, connecting_id)
		
		lobby_players.append(connecting_id)
		lobby_players.shuffle()
		
		start_game.rpc_id(lobby_players[0], lobby_players[1], true)
		start_game.rpc_id(lobby_players[1], lobby_players[0], false)
	else:
		lobbies[lobby_key] = [connecting_id]

@rpc("authority", "reliable")
func start_game(opponent_id: int, is_player1: bool):
	local_opponent_id = opponent_id
	
	Settings.MPPlayer1 = is_player1
	SceneNavigation.go_to_game(true)


@rpc("any_peer", "reliable")
func send_move(tile_index: int, tile_type: int):
	on_move_confirmed.emit(tile_index, tile_type)

@rpc("any_peer", "reliable")
func write_to_console(author: String, message: String):
	Console.write(author, message)

func on_peer_connected(id: int):
	if id == 1: # Register lobby when connecting to the server
		start_lobby.rpc_id(id, Settings.MPKey)

func on_peer_disconnected(id: int):
	local_opponent_id = 0

func on_client_disconnected(id: int):
	if not id in players: # skip if player connection was invalid (e.g. 3rd player in the same lobby)
		return
	
	var player_info: PlayerInfo = players[id]
	players.erase(id)
	
	if not player_info.lobby_key in lobbies:
		return
	
	write_to_console.rpc_id(player_info.opponent_id, "Server", "Player " + ("1" if id == lobbies[player_info.lobby_key][0] else "2") + " disconnected!!!")
	lobbies.erase(player_info.lobby_key)

func _ready() -> void:
	if DisplayServer.get_name() == "headless":
		start_server()
		
		multiplayer.peer_disconnected.connect(on_client_disconnected)
	else:
		multiplayer.peer_connected.connect(on_peer_connected)
		multiplayer.peer_disconnected.connect(on_peer_disconnected)

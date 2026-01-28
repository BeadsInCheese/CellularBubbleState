extends Node

var peer: WebSocketMultiplayerPeer

const PORT: int = 25565

class PlayerInfo:
	var lobby_key: String
	var opponent_id: int
	var is_player1: bool
	
	func _init(lobby_key: String, opponent_id: int, is_player1: bool) -> void:
		self.lobby_key = lobby_key
		self.opponent_id = opponent_id
		self.is_player1 = is_player1

var lobbies: Dictionary = {} # key: lobby_key, value: Array<int> (player_id array)
var players: Dictionary = {} # key: player_id, value: PlayerInfo

var local_opponent_id: int = 0 # id of the current opponent. 0 if not connected to a game

signal on_move_confirmed(tile_index: int, tile_type: int)

func start_server() -> void:
	peer = WebSocketMultiplayerPeer.new()
	var error = peer.create_server(PORT, "*", TLSOptions.server(load("res://privkey.key"), load("res://fullchain.crt")))
	if error:
		print("Failed to start server on port ", PORT, ". Error: ", error_string(error))
		return
	
	multiplayer.multiplayer_peer = peer

func connect_client() -> void:
	if peer == null:
		peer = WebSocketMultiplayerPeer.new()

	peer.create_client("wss://" + get_server_ip() + ":" + str(PORT))
	
	multiplayer.multiplayer_peer = peer

func disconnect_client() -> void:
	if peer != null:
		peer.close()
	
	local_opponent_id = 0


func get_server_ip() -> String:
	var config = ConfigFile.new()
	var load_status = config.load("res://config/INI_Settings.cfg")

	if load_status != OK:
		return "127.0.0.1"

	return config.get_value("MULTIPLAYER", "SERVER_IP", "127.0.0.1")

@rpc("any_peer", "reliable")
func connect_lobby(lobby_key: String):
	var connecting_id = multiplayer.get_remote_sender_id()
	
	if not lobby_key in lobbies:
		print("Creating lobby ", lobby_key, " by client ", connecting_id)
		lobbies[lobby_key] = [connecting_id] # add a new lobby key on the first connection and return
		return
	
	var lobby_players: Array = lobbies[lobby_key]
	if len(lobby_players) != 1:
		return # if lobby is full, discard additional players

	var opponent_id = lobby_players[0]
	lobby_players.append(connecting_id)

	if opponent_id in players:
		reconnect_lobby(connecting_id, opponent_id, lobby_key)
		return
	
	print("Starting lobby ", lobby_key, " for clients ", connecting_id, " and ", opponent_id)
	
	var sides: bool = randi() & 1
	
	players[connecting_id] = PlayerInfo.new(lobby_key, opponent_id, sides)
	players[opponent_id] = PlayerInfo.new(lobby_key, connecting_id, !sides)
	
	start_game.rpc_id(connecting_id, opponent_id, sides)
	start_game.rpc_id(opponent_id, connecting_id, !sides)

func reconnect_lobby(connecting_id: int, opponent_id: int, lobby_key: String):
	# continuing a disconnected game...
	print("Client ", connecting_id, " reconnecting to lobby ", lobby_key)
	
	players[connecting_id] = PlayerInfo.new(lobby_key, opponent_id, !players[opponent_id].is_player1)
	players[opponent_id].opponent_id = connecting_id
	
	resend_game_to_opponent.rpc_id(opponent_id, connecting_id)
	

@rpc("authority", "reliable")
func start_game(opponent_id: int, is_player1: bool):
	local_opponent_id = opponent_id
	
	Settings.MPPlayer1 = is_player1
	SceneNavigation.go_to_game(true)

@rpc("any_peer", "reliable")
func resend_game_to_opponent(opponent_id: int):
	local_opponent_id = opponent_id
	write_to_console("Server", "Player " + ("1" if !Settings.MPPlayer1 else "2") + " reconnected!!!")
	
	var board: Board = get_tree().root.get_node("root/Board")
	resync_game.rpc_id(opponent_id, !Settings.MPPlayer1, board.boardHistory, Console.get_log())

@rpc("any_peer", "reliable")
func resync_game(is_player1: bool, board_history: Array[String], console_history: String):
	local_opponent_id = multiplayer.get_remote_sender_id()
	
	Settings.MPPlayer1 = is_player1
	Settings.MPResumeHistory = board_history
	Settings.MPConsoleHistory = console_history
	SceneNavigation.go_to_game(true)
	

@rpc("any_peer", "reliable")
func send_move(tile_index: int, tile_type: int):
	on_move_confirmed.emit(tile_index, tile_type)

@rpc("any_peer", "reliable")
func write_to_console(author: String, message: String):
	Console.write(author, message)

func on_peer_connected(id: int):
	if id == 1: # Register lobby when connecting to the server
		connect_lobby.rpc_id(id, Settings.MPKey)

func on_peer_disconnected(id: int):
	local_opponent_id = 0

func on_client_disconnected(id: int):
	print("Client ", id, " disconnected.")
	
	if not id in players: # skip if player connection was invalid (e.g. 3rd player in the same lobby)
		return
	
	var player_info: PlayerInfo = players[id]
	players.erase(id)
	
	if not player_info.lobby_key in lobbies:
		return
	
	var lobby_players: Array = lobbies[player_info.lobby_key]
	lobby_players.erase(id)
	
	if len(lobby_players) == 0:
		lobbies.erase(player_info.lobby_key) # remove lobby when the last player disconnects -> lobby becomes empty
		return
	
	write_to_console.rpc_id(player_info.opponent_id, "Server", "Player " + ("1" if player_info.is_player1 else "2") + " disconnected!!!")

func _ready() -> void:
	if DisplayServer.get_name() == "headless" or OS.has_feature("dedicated_server"):
		start_server()
		
		multiplayer.peer_disconnected.connect(on_client_disconnected)
	else:
		multiplayer.peer_connected.connect(on_peer_connected)
		multiplayer.peer_disconnected.connect(on_peer_disconnected)

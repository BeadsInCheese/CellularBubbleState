extends AgentBase
class_name MultiplayerAgent

var connected = true

var latest_board_history = null
var latest_tile_index = -1
var latest_tile_type = -1

func init(board: Board):
	board.p1AgentInstance.moveMade.connect(send_move)
	NetCode.on_move_confirmed.connect(on_move_received)
	
	synchronize_turn_order(board)

func synchronize_turn_order(board: Board):
	if(Settings.MPPlayer1):
		return
	
	# Swap multiplayer agent with player agent if player 2
	var temp=board.p1AgentInstance
	board.p1AgentInstance=board.p2AgentInstance
	board.p2AgentInstance=temp
	board.p1AgentInstance.playerType=1
	board.p2AgentInstance.playerType=3


func send_move(board: Board):
	var tile_index = board.lastMove[0]
	var tile_type = board.lastMove[1]
	
	NetCode.request_move.rpc_id(1, NetCode.multiplayer.get_unique_id(), tile_index, tile_type, Settings.MPKey)

func on_move_received(tile_index: int, tile_type: int):
	latest_tile_index = tile_index
	latest_tile_type = tile_type

func makeMove(observation:Board):
	while latest_tile_index == -1 or latest_tile_type == -1:
		if observation == null or not observation.exists():
			return

		await observation.get_tree().process_frame
	
	if not connected:
		DataUtility.save_to_file(latest_board_history, "save-"+Time.get_datetime_string_from_system(),"res://Saves")
		SceneNavigation.goToMultiplayerSelection()
		return
	
	print("Received data: ", latest_tile_index,"  , ", latest_tile_type)
	observation.gridList[latest_tile_index].setTileType(observation.turnOrder[observation.currentTurn].playerType)
	latest_board_history = observation.boardHistory
	latest_tile_index = -1
	latest_tile_type = -1
	
	return [latest_tile_index, latest_tile_type]

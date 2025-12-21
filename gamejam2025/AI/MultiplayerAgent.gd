extends AgentBase
class_name MultiplayerAgent

var client = StreamPeerTCP.new()
var connected = false
var latestBoardHistory = null
var done=false

func init(board: Board):
	client=NetCode.client
	connected=true
	await synchronize_turn_order(board)

func synchronize_turn_order(board: Board):
	while connected:
		await board.get_tree().process_frame
		
		if client.get_available_bytes() >= 4:
			client.poll()
			var x=client.get_32()
			print("got data: " + str(x))
			
			board.p1AgentInstance.moveMade.connect(send_move)
			
			if(x==1):
				var temp=board.p1AgentInstance
				
				board.p1AgentInstance=board.p2AgentInstance
				board.p2AgentInstance=temp
				board.p1AgentInstance.playerType=1
				board.p2AgentInstance.playerType=3
				return
			else:
				return
		else:		# Sleep for a short duration to avoid busy-waiting
			await board.get_tree().process_frame


func send_move(ob:Board):
	var tileIndex = ob.lastMove[0]
	var tileType = ob.lastMove[1]
	
	client.put_32(tileIndex)
	client.put_32(tileType)
	
	print("Sent integers: ", tileIndex, ", ", tileType)


func makeMove(observation:Board):
	if(observation!=null):
		await observation.get_tree().process_frame
	while !done and connected:
		client.poll()
		client.poll()
		
		if client.get_status() != StreamPeerTCP.STATUS_CONNECTED:
			DataUtility.save_to_file(latestBoardHistory, "save-"+Time.get_datetime_string_from_system(),"res://Saves")
			SceneNavigation.goToMultiplayerSelection()
			connected = false
		
		if client.get_available_bytes() > 0:
				var tileIndex = client.get_32()
				var tileType = client.get_32()
				print("Received data: ", tileIndex,"  , ", tileType)
				observation.gridList[tileIndex].setTileType(observation.turnOrder[observation.currentTurn].playerType)
				latestBoardHistory = observation.boardHistory
				
				return [tileIndex, tileType]

		if(observation!=null):
			await observation.get_tree().process_frame
		else:
			return

	if(observation!=null):
		await observation.get_tree().process_frame

extends AgentBase
class_name MultiplayerAgent


var client = StreamPeerTCP.new()
var connected = false
func init(board:Board):
	await connect_to_server("127.0.0.1")
	connected=true
	await syncronizeTurnOrder(board)
	print("MultiplayerAgent Ready")
func syncronizeTurnOrder(board:Board):
	while connected:
		print(client.get_available_bytes())
		await board.get_tree().process_frame
		if client.get_available_bytes() >= 4:
			client.poll()
			var x=client.get_32()
			print("got data: "+str(x))
			
			board.p1AgentInstance.moveMade.connect(sendOb)
			#board.p2AgentInstance.moveMade.connect(syncronize)
			
			if(x==1):
				var temp=board.p1AgentInstance
				
				board.p1AgentInstance=board.p2AgentInstance
				board.p2AgentInstance=temp
				return
			else:
				return
		else:		# Sleep for a short duration to avoid busy-waiting
			await board.get_tree().process_frame

	
	
func connect_to_server(host: String) -> void:
	client=NetCode.client
func _blocking_read(observation:Board):
	while connected:
		if client.get_available_bytes() >= 4:
			print("message")
			client.poll()
			var x=client.get_32()
			var v=client.get_32()
			print("Received data: ", x,"  , ",v)
			return [x,v]
		else:
			# Sleep for a short duration to avoid busy-waiting
			await observation.get_tree().process_frame
func sendOb(ob:Board):
	send(ob.lastMove[0],ob.lastMove[1])
func send(x:float,v:int) -> bool:
	print("sending data...")
	client.put_32(x)
	client.put_32(v)
	print("Sent integers: ", x, ", ", v)
	return true
	print("connection lost")
	return false
func syncronize(observation:Board):
	print("syncronizing...")
	var temp=await _blocking_read(observation)
	if(temp[0]==-1):
		print("INVALID")
		syncronize(observation)
		return
		pass
	print(temp)
	if(true or observation.gridList[temp[0]].tileType==0):
		observation.gridList[temp[0]].setTileType(observation.turnOrder[observation.currentTurn].playerType)
		done=true
	else:
		print("DESYNC")
		
# Called when the node enters the scene tree for the first time.
var done=false
func makeMove(observation:Board):
	while !done and connected:
		client.poll()
		print(client.get_available_bytes())
		if client.get_available_bytes() >0:
				print("message")
				var x=client.get_32()
				var v=client.get_32()
				print("Received data: ", x,"  , ",v)
				observation.gridList[x].setTileType(observation.turnOrder[observation.currentTurn].playerType)
				
				return [x,v]
		if(observation!=null):
			await observation.get_tree().process_frame
		else:
			return
			
	if(observation!=null):
		await observation.get_tree().process_frame
	#await send(observation.lastMove[0],observation.lastMove[1])
	#await syncronize(observation)


# Called every frame. 'delta' is the elapsed time since the previous frame.

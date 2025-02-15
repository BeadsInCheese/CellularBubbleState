
class_name AgentBase
var isPlayer=false
signal moveMade(board:Board)
var playerType=1
var skip=false
func init(board:Board):
	pass
func makeMove(observation:Board):
	pass
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
func makeRandomMove(observation:Board):
	var x=randi()%100
	var offset=0
	await observation.get_tree().create_timer(0.1).timeout
	for i in range(x):
		while(observation.gridList[(i+offset)%len(observation.gridList)].tileType!=0):
			offset+=1
			if(offset>100000):
				return
	observation.gridList[(x+offset-1)%len(observation.gridList)].setTileType(playerType)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func get_custom_class_name():
	return "AgentBase"
func get_is_player() -> bool:
	return false

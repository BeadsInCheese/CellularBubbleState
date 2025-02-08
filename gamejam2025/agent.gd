extends Node
class_name Agent

var agentColor
var DPU_list : Array[DynamicalProcessingUnit] = []

func update(x,y,p):
	for dpu in DPU_list:
		dpu.update(x,y,p)

func init_dpu():
	var j = 1
	for i in range(1,100):
		var u : DynamicalProcessingUnit = DynamicalProcessingUnit.new()
		u.id = i
		u.offsetX = floor(i/10) + 1
		u.offsetY = j
		DPU_list.append(u)
		j = (j+1) % 10

func compute_heuristic(n):
	pass


func compute_metric(n):
	pass
	
	
func proceduralMove(currentTurn,color,board) -> Bubble:
	var m = 0
	var i = 237
	var result = 0
	
	while m < 500:
		i = (int)(1000*(1000*sin(i+19)-(int)(1000*sin(i+19)))) % len(board)
		m = m+1
		if board[i].tileType == 0:
			result = i
			break;
	return board[result]
	
######################################################
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

extends Node2D

func _ready() -> void:
	NetCode.start_client()

func _exit_tree() -> void:
	print("EXITTTTTTTTTTTTTTTTTTTTTTTT")

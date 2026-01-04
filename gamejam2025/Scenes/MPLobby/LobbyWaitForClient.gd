extends Node2D

func _ready() -> void:
	NetCode.start_client()

func _exit_tree() -> void:
	NetCode.disconnect_client()

func _on_back_button_pressed() -> void:
	SceneNavigation.go_to_main_menu()

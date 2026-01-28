extends Node2D


func _ready() -> void:
	AutomataAgent.ruleset_name="vanilla"


func go_to_settings() -> void:
	SceneNavigation.go_to_settings()

func go_to_player_selection() -> void:
	SceneNavigation.go_to_player_selection()

func go_to_multiplayer_selection() -> void:
	SceneNavigation.go_to_multiplayer_selection()

func go_to_tutorial() -> void:
	Board.mp = false
	Board.tutorial = true
	SceneNavigation.go_to_game()


func _on_credits_pressed() -> void:
	SceneNavigation.go_to_credits()

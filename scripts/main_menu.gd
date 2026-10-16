extends CanvasLayer

@onready var play: Button = $Control/Play
@onready var settings: Button = $Control/Settings
@onready var exit: Button = $Control/Exit

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_settings_pressed() -> void:
	pass # Replace with function body.

func _on_exit_pressed() -> void:
	get_tree().quit()

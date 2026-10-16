extends CanvasLayer

@onready var status_label: Label = $Control/StatusLabel

func _ready() -> void:
	if Autoload.won:
		status_label.text = "You Won"
	else:
		status_label.text = "You Lost"

func _on_restart_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

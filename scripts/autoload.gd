extends Node

enum Stage { COLLECT, DEFEND }

var current_stage: Stage = Stage.COLLECT

var player_node: Node2D = null

func change_stage(new_stage: Stage) -> void:
	current_stage = new_stage

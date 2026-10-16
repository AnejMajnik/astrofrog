extends Node

enum Stage { COLLECT, DEFEND }

var current_stage: Stage = Stage.COLLECT

var player_node: Node2D = null
var antenna_node: Node2D = null
var won: bool = false
var seen_story: bool = false

func change_stage(new_stage: Stage) -> void:
	current_stage = new_stage

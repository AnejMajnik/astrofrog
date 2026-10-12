extends Node

enum Stage { COLLECT, DEFEND }

var current_stage: Stage = Stage.COLLECT

var player_node: Node2D = null

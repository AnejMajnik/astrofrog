extends Node2D

var asteroid = preload("res://scenes/asteroid.tscn")
var asteroid_big = preload("res://scenes/asteroid_big.tscn")
var enemy = preload("res://scenes/enemy.tscn")
@onready var background: TileMapLayer = $Background

var map_width_tiles: int = 500
var map_height_tiles: int = 400

@export var atlas_start_coord: Vector2i = Vector2i(0, 0)
@export var grid_size: Vector2i = Vector2i(4, 4)
@onready var asteroid_spawn_timer: Timer = $AsteroidSpawnTimer
@onready var ui: CanvasLayer = $UI
@onready var player: CharacterBody2D = $Player

@export var ores: Array[OreData]
@export var ore_normal: OreData
@export var ore_amethyst: OreData
@export var ore_emerald: OreData
@export var ore_ruby: OreData

var tile_options: Array[Vector2i] = []

func build_map():
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			var coord = atlas_start_coord + Vector2i(x, y)
			if x == 0 and y == 0:
				for i in range(10):
					tile_options.append(coord)
			else:
				tile_options.append(coord)
				
	var half_w = map_width_tiles/2
	var half_h = map_height_tiles/2
	
	# Generate background
	for x in range(-half_w, half_w):
		for y in range(-half_h, half_h):
			var random_tile = tile_options.pick_random()
			background.set_cell(Vector2i(x, y), 1 , random_tile)
	
func _ready() -> void:
	build_map()
	spawn_asteroids(25, true)
	spawn_enemies(20, false)
	ui.setup_ability(player.ability_timer)
	player.health_changed.connect(ui.set_health)
	player.died.connect(_on_player_died)
	asteroid_spawn_timer.start()
	ui.set_health(player.health, player.max_health)
	ui.setup_inventory(player.inventory)

func _on_player_died() -> void:
	print("game_over")

func pick_ore() -> OreData:
	var roll := randf()
	if roll < 0.85:
		return ore_normal
	elif roll < 0.9:
		return ore_amethyst
	elif roll < 0.95:
		return ore_emerald
	else:
		return ore_ruby

func spawn_asteroids(count: int, offscreen: bool = true):
	for i in count:
		var instance = (asteroid if randf() < 0.75 else asteroid_big).instantiate()
		instance.ore = pick_ore()

		if offscreen:
			instance.position = get_offscreen_position()
		else:
			instance.position = Vector2(randf_range(-2000, 2000), randf_range(-1000, 1000))
		add_child(instance)
		
func spawn_enemies(count: int, offscreen: bool = true):
	for i in count:
		var instance = enemy.instantiate()
		
		if offscreen:
			instance.position = get_offscreen_position()
		else:
			instance.position = Vector2(randf_range(-3000, 3000), randf_range(-2000, 2000))
		add_child(instance)

func get_offscreen_position(margin := 100) -> Vector2:
	var rect: Rect2 = get_canvas_transform().affine_inverse() * get_viewport_rect()
	var radius := rect.size.length() / 2.0 + margin
	return rect.get_center() + Vector2.from_angle(randf_range(0.0, TAU)) * radius

func _on_asteroid_spawn_timer_timeout() -> void:
	spawn_asteroids(7)
	asteroid_spawn_timer.start()

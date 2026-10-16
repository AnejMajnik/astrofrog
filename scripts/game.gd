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
@onready var pop_up: CanvasLayer = $PopUp
@onready var antenna: StaticBody2D = $Antenna
@onready var enemy_defend_spawn_timer: Timer = $EnemyDefendSpawnTimer

@export var ores: Array[OreData]
@export var ore_normal: OreData
@export var ore_amethyst: OreData
@export var ore_emerald: OreData
@export var ore_ruby: OreData

const ITEM_AMETHYST = preload("uid://dv8kjhexwky3r")
const ITEM_EMERALD = preload("uid://c6sag2shd3vwe")
const ITEM_RUBY = preload("uid://b4oeursth0cli")

var need: int = 1
var emerald_count: int = 0
var ruby_count: int = 0
var amethyst_count: int = 0

var tile_options: Array[Vector2i] = []

var spawn_rect := Rect2(Vector2(-1000, -1700), Vector2(2000, 1000))

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
	Autoload.won = false
	build_map()
	spawn_asteroids(50, true)
	spawn_enemies(10, true)
	ui.setup_ability(player.ability_timer)
	player.health_changed.connect(ui.set_health)
	player.died.connect(_on_player_died)
	asteroid_spawn_timer.start()
	ui.set_health(player.health, player.max_health)
	ui.setup_inventory(player.inventory)
	start_story()

func start_story() -> void:
	pop_up.open("Welcome", "Welcome to Astro Frog.\nThe Frog Space Station (FSS) has lost signal with the earth\nbecause of an asteroid impact.", [{"id": "story1", "text": "Next"}])

func _on_player_died() -> void:
	get_tree().change_scene_to_file("res://scenes/end_screen.tscn")

func pick_ore() -> OreData:
	var roll := randf()
	if roll < 0.1: #0.85
		return ore_normal
	elif roll < 0.4: #0.9
		return ore_amethyst
	elif roll < 0.7: #0.95
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
		
func spawn_enemies_defend(count: int):
	for i in count:
		var enemy_spawn = enemy.instantiate()
		enemy_spawn.global_position = Vector2(
			randf_range(spawn_rect.position.x, spawn_rect.end.x),
			randf_range(spawn_rect.position.y, spawn_rect.end.y)
		)
		get_tree().current_scene.add_child(enemy_spawn)
		
	enemy_defend_spawn_timer.start()

func get_offscreen_position(margin := 100, spread := 1500) -> Vector2:
	var rect: Rect2 = get_canvas_transform().affine_inverse() * get_viewport_rect()
	var radius := rect.size.length() / 2.0 + margin + randf_range(0.0, spread)
	return rect.get_center() + Vector2.from_angle(randf_range(0.0, TAU)) * radius

func _on_asteroid_spawn_timer_timeout() -> void:
	spawn_asteroids(10, true)
	asteroid_spawn_timer.start()
	
func _on_antenna_show_popup_antenna(should_show: bool) -> void:
	pop_up.visible = should_show
	amethyst_count = player.inventory.get_amount(ITEM_AMETHYST)
	ruby_count = player.inventory.get_amount(ITEM_RUBY)
	emerald_count = player.inventory.get_amount(ITEM_EMERALD)
	if amethyst_count >= need and ruby_count >= need and emerald_count >= need:
		pop_up.open(
			"Deposit materials to fix the antenna",
			"Amethyst: %d / %d\nEmerald: %d / %d\nRuby: %d / %d" % [amethyst_count, need, emerald_count, need, ruby_count, need],
			[{"id": "deposit", "text": "Deposit"}, {"id": "close", "text": "Close"}]
		)
	else:
		pop_up.open(
			"Deposit materials to fix the antenna",
			"Amethyst: %d / %d\nEmerald: %d / %d\nRuby: %d / %d" % [amethyst_count, need, emerald_count, need, ruby_count, need],
			[{"id": "close", "text": "Close"}]
		)

func _on_pop_up_button_pressed(id: String) -> void:
	if id == "deposit":
		player.inventory.remove(ITEM_AMETHYST, need)
		player.inventory.remove(ITEM_EMERALD, need)
		player.inventory.remove(ITEM_RUBY, need)
		Autoload.change_stage(Autoload.Stage.DEFEND)
		get_tree().call_group("enemy", "queue_free")
		antenna.disable_deposit_area()
		enemy_defend_spawn_timer.start()
		ui.start_defense_timer()
		
		pop_up.open(
			"Oh Nooo", 
			"Watch out, the enemies are swarming.\nDefend the antenna until the repair is done!.",
			[{"id": "close", "text": "Close"}]
		)
	elif id == "story1":
		pop_up.open(
			"We Have a Problem", 
			"The antenna we use to communicate\nwith the earth has been damaged.\n", 
			[{"id": "story2", "text": "Next"}]
		)
	elif id == "story2":
		pop_up.open(
			"The Repair", 
			"To repair it, we need precious minerals.\nCollect:\n5 Amethyst, 5 Emerald and 5 Ruby\nfrom asteroids to initiate repair.", 
			[{"id": "story3", "text": "Next"}]
		)
	elif id == "story3":
		pop_up.open(
			"Good Luck", 
			"Oh, and be careful.\nThere are evil frogs, looking for those precious minerals.", 
			[{"id": "story4", "text": "Done"}]
		)


func _on_enemy_defend_spawn_timer_timeout() -> void:
	spawn_enemies_defend(3)

func _on_ui_timer_ended() -> void:
	Autoload.won = true
	get_tree().change_scene_to_file("res://scenes/end_screen.tscn")

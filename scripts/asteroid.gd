extends Area2D

var direction = 0
const damage = 1
var velocity: Vector2

@export var speed = 175
@export var health = 50
@export var max_distance := 2000
@export var ore: OreData
@export var big := false
@export var drop_amount := 2

@onready var player = Autoload.player_node
@onready var sprite_2d: Sprite2D = $Sprite2D
var rotation_amount

const PICKUP_SCENE := preload("res://scenes/pickup.tscn")

func _ready() -> void:
	$Sprite2D.texture = ore.big_texture if big else ore.small_texture
	direction = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0))
	velocity = direction * speed
	rotation_amount = randf_range(0.5, 4.0) * [-1, 1].pick_random()
	rotation = randf_range(0.0, TAU)
	
func flash_white() -> void:
	sprite_2d.material.set_shader_parameter("flash_color", Color(1.0, 1.0, 1.0, 1.0))
	
	var tween = create_tween()
	tween.tween_method(_set_flash, 1.0, 0.0, 0.2)

func _set_flash(value: float) -> void:
	sprite_2d.material.set_shader_parameter("flash_amount", value)

func take_damage(damage: int) -> void:
	health -= damage
	flash_white()
	
	if health <= 0:
		if ore.item:
			for i in drop_amount:
				var pickup = PICKUP_SCENE.instantiate()
				pickup.item = ore.item
				pickup.amount = 1
				pickup.global_position = global_position + Vector2.from_angle(randf_range(0.0, TAU)) * randf_range(5.0, 25.0)
				get_tree().current_scene.call_deferred("add_child", pickup)
		queue_free()
	
func _physics_process(delta: float) -> void:
	for body in get_overlapping_bodies():
		if body.is_in_group("player"):
			body.take_damage(damage)
			take_damage(health)
		elif body.is_in_group("fss"):
			queue_free()
	
	rotation += rotation_amount * delta
	
	position += velocity * delta
	if global_position.distance_to(player.global_position) > max_distance:
		queue_free()

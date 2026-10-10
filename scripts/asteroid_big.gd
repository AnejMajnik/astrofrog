extends Area2D

var direction = 0
@export var speed = 125
const damage = 1
var velocity: Vector2
var health = 100

@export var max_distance := 2000

@onready var player = Autoload.player_node
var rotation_amount

func _ready() -> void:
	direction = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0))
	velocity = direction * speed
	rotation_amount = randf_range(0.5, 4.0) * [-1, 1].pick_random()
	rotation = randf_range(0.0, TAU)
	
func take_damage(damage: int) -> void:
	health -= damage
	
	if health <= 0:
		queue_free()
	
func _physics_process(delta: float) -> void:
	for body in get_overlapping_bodies():
		if body.is_in_group("player"):
			body.take_damage(damage)
			queue_free()
		elif body.is_in_group("fss"):
			queue_free()
	
	rotation += rotation_amount * delta
	
	position += velocity * delta
	if global_position.distance_to(player.global_position) > max_distance:
		queue_free()

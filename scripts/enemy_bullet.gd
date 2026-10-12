extends Area2D

var velocity: Vector2
var speed := 500.0
var damage: int = 1
@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	velocity = Vector2.from_angle(rotation) * speed

func _physics_process(delta: float) -> void:
	position += velocity * delta
	
	for body in get_overlapping_bodies():
		if body.is_in_group("player") or body.is_in_group("antenna"):
			body.take_damage(damage)
			queue_free()

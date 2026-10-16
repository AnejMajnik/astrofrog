extends Area2D

var velocity: Vector2
var speed := 500.0
var damage: int = 25
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var cpu_particles_2d: CPUParticles2D = $CPUParticles2D

func _ready() -> void:
	velocity = Vector2.from_angle(rotation) * speed

func _physics_process(delta: float) -> void:
	position += velocity * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		body.take_damage(damage)
		set_deferred("monitoring", false)
		sprite_2d.hide()
		cpu_particles_2d.emitting = true
		await get_tree().create_timer(cpu_particles_2d.lifetime).timeout
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("asteroid"):
		area.take_damage(damage)
		set_deferred("monitoring", false)
		sprite_2d.hide()
		cpu_particles_2d.emitting = true
		await get_tree().create_timer(cpu_particles_2d.lifetime).timeout
		queue_free()

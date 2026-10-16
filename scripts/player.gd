extends CharacterBody2D

@export var speed = 200
var move_speed = speed
@export var boost_speed = 400
@export var decceleration_speed = 400
@export var acceleration_speed = 400
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var shoot_timer: Timer = $ShootTimer
@onready var ability_timer: Timer = $AbilityTimer
@onready var inventory: Inventory = $Inventory
@onready var laser_sound: AudioStreamPlayer2D = $LaserSound
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var max_health = 5
var health
var bullet = preload("res://scenes/laser_bullet.tscn")
var can_shoot: bool = true
var can_ability: bool = true
var push_strength = 500

var character_direction: Vector2

signal health_changed(current: int, maximum: int)
signal died

func _ready() -> void:
	Autoload.player_node = self
	health = max_health

func flash_take_damage() -> void:
	animated_sprite.material.set_shader_parameter("flash_color", Color(1.0, 1.0, 1.0, 1.0))
	var tween = create_tween()
	tween.tween_method(_set_flash, 1.0, 0.0, 0.2)

func _set_flash(value: float) -> void:
	animated_sprite.material.set_shader_parameter("flash_amount", value)

func take_damage(dmg: int) -> void:
	if health <= 0:
		return
		
	health = clampi(health - dmg, 0, max_health)
	health_changed.emit(health, max_health)
	flash_take_damage()
	
	if health == 0:
		died.emit()
		print("ded")

func shoot() -> void:
	var instance = bullet.instantiate()
	instance.global_position = to_global(Vector2(0, -25))
	instance.rotation = rotation - PI/2
	get_tree().current_scene.add_child(instance)
	laser_sound.play()
	can_shoot = false
	shoot_timer.start()
	
func shoot_ability() -> void:
	can_ability = false
	for wave in 3:
		laser_ring(12, wave * TAU / 36)
		await get_tree().create_timer(0.2).timeout
	
	ability_timer.start()
		
func laser_ring(count: int, offset := 0.0) -> void:
	for i in count:
		var instance = bullet.instantiate()
		instance.global_position = global_position
		instance.rotation = offset + i * TAU / count
		laser_sound.play()
		get_tree().current_scene.add_child(instance)

func _physics_process(delta: float) -> void:
	character_direction.x = Input.get_axis("left", "right")
	character_direction.y = Input.get_axis("up", "down")
	character_direction = character_direction.normalized()
	
	if Input.is_action_just_pressed("boost"):
		move_speed = boost_speed
	
	if Input.is_action_just_released("boost"):
		move_speed = speed
		
	if Input.is_action_just_pressed("shoot") and can_shoot:
		shoot()
		
	if Input.is_action_just_pressed("ability") and can_ability:
		shoot_ability()
	
	if character_direction:
		animation_player.play("move")
		velocity = velocity.move_toward(character_direction * move_speed, acceleration_speed * delta)
	else:
		animation_player.play("idle")
		velocity = velocity.move_toward(Vector2.ZERO, decceleration_speed * delta)
		
	if character_direction != Vector2.ZERO:
		rotation = lerp_angle(rotation, character_direction.angle() + PI / 2, 10.0 * delta)
		
	move_and_slide()

func _on_shoot_timer_timeout() -> void:
	can_shoot = true


func _on_ability_timer_timeout() -> void:
	can_ability = true

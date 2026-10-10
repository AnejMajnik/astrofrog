extends CharacterBody2D

@export var speed = 200
var move_speed = speed
@export var boost_speed = 400
@export var decceleration_speed = 10
@export var acceleration_speed = 10
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var shoot_timer: Timer = $ShootTimer
@onready var ability_timer: Timer = $AbilityTimer

var health = 3
var bullet = preload("res://scenes/laser_bullet.tscn")
var can_shoot: bool = true
var can_ability: bool = true

var character_direction: Vector2

func _ready() -> void:
	Autoload.player_node = self

func take_damage(dmg: int) -> void:
	health -= dmg
	
	if health <= 0:
		print("ded")

func shoot() -> void:
	var instance = bullet.instantiate()
	instance.global_position = to_global(Vector2(0, -25))
	instance.rotation = rotation - PI/2
	get_tree().current_scene.add_child(instance)
	can_shoot = false
	shoot_timer.start()
	
func shoot_ability() -> void:
	for wave in 3:
		laser_ring(12)
		await get_tree().create_timer(0.2).timeout
	
	can_ability = false
	ability_timer.start()
		
func laser_ring(count: int) -> void:
	for i in count:
		var instance = bullet.instantiate()
		instance.global_position = global_position
		instance.rotation = i * TAU / count
		get_tree().current_scene.add_child(instance)

func _physics_process(_delta: float) -> void:
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
		velocity = velocity.move_toward(character_direction * move_speed, acceleration_speed)
	else:
		animation_player.play("idle")
		velocity = velocity.move_toward(Vector2.ZERO, decceleration_speed)
		
	if character_direction != Vector2.ZERO:
		rotation = character_direction.angle() + PI/2
		
	move_and_slide()


func _on_shoot_timer_timeout() -> void:
	can_shoot = true


func _on_ability_timer_timeout() -> void:
	can_ability = true

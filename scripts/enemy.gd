extends CharacterBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var idle_timer: Timer = $IdleTimer
@onready var player: CharacterBody2D = Autoload.player_node

enum State { IDLE, ROAM, ATTACK, DIE }
var current_state: State
var home_location: Vector2
var other_location: Vector2
var target_location: Vector2
var going_to_other := true
var direction: int
var move_speed = 175
var decceleration_speed = 300
var acceleration_speed = 300
var turn_speed = 8.0

func _ready() -> void:
	home_location = global_position
	other_location.x = home_location.x + [-1, 1].pick_random() * 500
	other_location.y = home_location.y
	change_state(State.IDLE)

func change_state(new_state: State) -> void:
	current_state = new_state
	match new_state:
		State.IDLE:
			animation_player.play("idle")
			idle_timer.start()
		State.ROAM:
			animation_player.play("move")
			target_location = other_location if going_to_other else home_location
			going_to_other = !going_to_other
		State.ATTACK:
			animation_player.play("move")

func _physics_process(delta: float) -> void:
	match current_state:
		State.IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, decceleration_speed * delta)
		State.ROAM:
			direction = sign(target_location.x - global_position.x)
			var distance = target_location.x - global_position.x
			if abs(distance) <= move_speed * delta:
				change_state(State.IDLE)
			velocity = velocity.move_toward(Vector2(direction, 0) * move_speed, acceleration_speed * delta)
		State.ATTACK:
			velocity = velocity.move_toward(global_position.direction_to(player.global_position) * move_speed, acceleration_speed * delta)
	move_and_slide()
	
	# Rotate
	if velocity.length() > 10.0:
		rotation = lerp_angle(rotation, velocity.angle() + PI / 2, turn_speed * delta)

func _on_idle_timer_timeout() -> void:
	change_state(State.ROAM)


func _on_aggro_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		change_state(State.ATTACK)

extends StaticBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar: ProgressBar = $HealthBar
@onready var notice: Label = $Notice
@onready var deposit_area: Area2D = $DepositArea

var max_health := 50
var health = 0
var player_in_area := false

signal show_popup_antenna(should_show: bool)

func _ready() -> void:
	Autoload.antenna_node = self
	animated_sprite_2d.play("broken")
	health_bar.max_value = max_health
	health_bar.value = health

func take_damage(damage: int) -> void:
	if Autoload.current_stage == Autoload.Stage.DEFEND:
		health = maxi(health - damage, 0)
		health_bar.value = health
		
		if health <= 0:
			get_tree().change_scene_to_file("res://scenes/end_screen.tscn")

func transition_into_defense() -> void:
	health = max_health
	health_bar.value = health
	animated_sprite_2d.play("repaired")

func disable_deposit_area() -> void:
	deposit_area.monitoring = false
	
func _input(_event: InputEvent) -> void:
	if Input.is_action_pressed("interact") and player_in_area:
		show_popup_antenna.emit(true)

func _on_deposit_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		notice.visible = true
		player_in_area = true


func _on_deposit_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		notice.visible = false
		player_in_area = false

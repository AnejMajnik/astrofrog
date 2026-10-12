extends StaticBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar: ProgressBar = $HealthBar

var max_health := 20
var health = max_health

func _ready() -> void:
	animated_sprite_2d.play("broken")
	health_bar.max_value = max_health
	health_bar.value = health

func take_damage(damage: int) -> void:
	if Autoload.current_stage == Autoload.Stage.DEFEND:
		health = maxi(health - damage, 0)
		health_bar.value = health

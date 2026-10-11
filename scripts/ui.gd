extends CanvasLayer

@onready var ability_icon: TextureProgressBar = $Control/AbilityIcon

func setup_ability(timer: Timer) -> void:
	ability_icon.setup(timer)

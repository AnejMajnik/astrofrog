extends Area2D

var item: ItemData
var amount := 1
@onready var pickup_sound: AudioStreamPlayer2D = $PickupSound

func _ready() -> void:
	$Sprite2D.texture = item.icon
	body_entered.connect(_on_body_entered)
	
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.inventory.add(item, amount)
		set_deferred("monitoring", false)
		$Sprite2D.hide()
		pickup_sound.play()
		await pickup_sound.finished
		queue_free()

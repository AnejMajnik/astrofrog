extends Area2D

var item: ItemData
var amount := 1

func _ready() -> void:
	$Sprite2D.texture = item.icon
	body_entered.connect(_on_body_entered)
	
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.inventory.add(item, amount)
		queue_free()

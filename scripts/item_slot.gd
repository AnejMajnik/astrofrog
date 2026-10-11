extends VBoxContainer

@onready var icon: TextureRect = $Icon
@onready var amount: Label = $Amount

func setup(item: ItemData) -> void:
	icon.texture = item.icon
	set_amount(0)
	
func set_amount(n: int) -> void:
	amount.text = str(n)

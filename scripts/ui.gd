extends CanvasLayer

const SLOT_SCENE := preload("res://scenes/item_slot.tscn")

@onready var ability_icon: TextureProgressBar = $Control/AbilityIcon
@onready var health_bar: ProgressBar = $Control/HealthBar
@onready var items_bar: HBoxContainer = $Control/ItemsBar

@export var tracked_items: Array[ItemData]

var slots: Dictionary = {}

func _ready() -> void:
	for item in tracked_items:
		var slot = SLOT_SCENE.instantiate()
		items_bar.add_child(slot)
		slot.setup(item)
		slots[item] = slot

func setup_inventory(inventory: Inventory) -> void:
	inventory.changed.connect(_on_inventory_changed)

func set_health(current: int, maximum: int) -> void:
	print(current, "/", maximum)
	health_bar.max_value = maximum
	health_bar.value = current

func setup_ability(timer: Timer) -> void:
	ability_icon.setup(timer)

func _on_inventory_changed(item: ItemData, amount: int) -> void:
	if slots.has(item):
		slots[item].set_amount(amount)

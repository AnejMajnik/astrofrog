extends CanvasLayer

const SLOT_SCENE := preload("res://scenes/item_slot.tscn")

@onready var ability_icon: TextureProgressBar = $Control/AbilityIcon
@onready var health_bar: ProgressBar = $Control/HealthBar
@onready var items_bar: HBoxContainer = $Control/ItemsBar
@onready var defend_timer: Timer = $DefendTimer
@onready var timer: Label = $Control/Timer
@onready var notice: Label = $Control/Notice

var defending: bool = false

@export var tracked_items: Array[ItemData]

var slots: Dictionary = {}

signal timer_ended

func _ready() -> void:
	for item in tracked_items:
		var slot = SLOT_SCENE.instantiate()
		items_bar.add_child(slot)
		slot.setup(item)
		slots[item] = slot
		
	timer.grow_horizontal = Control.GROW_DIRECTION_BOTH

func _process(_delta: float) -> void:
	if defending:
		timer.text = str(ceili(defend_timer.time_left))

func start_defense_timer() -> void:
	defend_timer.start()
	defending = true
	notice.visible = true
	timer.visible = true

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


func _on_defend_timer_timeout() -> void:
	timer_ended.emit()

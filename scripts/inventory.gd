extends Node
class_name Inventory

signal changed(item: ItemData, new_amount: int)

var items: Dictionary = {}

func add(item: ItemData, amount: int) -> void:
	var total: int = mini(items.get(item, 0) + amount, item.max_stack)
	items[item] = total
	changed.emit(item, total)
	
func remove(item: ItemData, amount: int) -> bool:
	if items.get(item, 0) < amount:
		return false
	items[item] -= amount
	changed.emit(item, items[item])
	return true
	
func get_amount(item: ItemData) -> int:
	return items.get(item, 0)

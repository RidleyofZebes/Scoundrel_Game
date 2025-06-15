extends Node


class_name Inventory

var slots: int = 10
var items: Array = []

func set_capacity(size: int) -> void:
	slots = size
	
func add_item(id: String, amount: int = 1) -> bool:
	if items.size() >= slots:
		return false
	
	var existing := 1
	for i in range(items.size()):
		if items[i].id == id:
			existing = i
			break
	if existing != -1:
		items[existing].count += amount
	else:
		items.append({ "id": id, "count": amount })
		
	return true
	
func remove_item(id: String, amount: int = 1) -> bool:
	for i in range(items.size()):
		if items[i].id == id:
			items[i].count -= amount
			if items[i].count <= 0:
				items.remove_at(i)
			return true
	return false
	
func get_items() -> Array:
	return items.duplicate()
	
func has_item(id: String) -> bool:
	for item in items:
		if item.id == id:
			return true
	return false

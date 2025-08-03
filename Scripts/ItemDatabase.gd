extends Node


var item_defs := {}
var container_defs := {}

func _ready():
	load_items()
	load_containers()
	
func load_items():
	var file = FileAccess.open("res://Data/items.yaml", FileAccess.READ)
	if file:
		item_defs = YAML.parse(file.get_as_text()).get_data()
		file.close()
		
func load_containers():
	var file = FileAccess.open("res://Data/containers.yaml", FileAccess.READ)
	if file:
		container_defs = YAML.parse(file.get_as_text()).get_data()
		file.close()
		
func get_item_data(id: String) -> Dictionary:
	return item_defs.get(id, {})
	
func get_container_data(id: String) -> Dictionary:
	return container_defs.get(id, {})

extends Node
class_name TileRegistry

var tile_defs: Dictionary = {}

func _ready():
	var file = FileAccess.open("res://Data/tile_types.json", FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		tile_defs = JSON.parse_string(json_string)
	else:
		push_error("Could not load tile_types.json")

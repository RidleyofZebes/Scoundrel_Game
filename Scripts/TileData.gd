extends Node
class_name TileRegistry

var tile_defs: Dictionary = {}
var tile_json_path: String = "res://Data/Dungeon_Tiles.json"

func load_tiles(path: String = ""):
	if path != "":
		tile_json_path = path
		
	var file = FileAccess.open(tile_json_path, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		tile_defs = JSON.parse_string(json_string)
	else:
		push_error("Could not load " + tile_json_path)

func _ready():
	load_tiles()

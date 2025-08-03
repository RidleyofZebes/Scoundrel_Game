extends Node
class_name TileRegistry

var tile_defs
var tile_yaml_path: String = "res://Data/Dungeon_Tiles.yaml"

func load_tiles(path: String = ""):
	if path != "":
		tile_yaml_path = path
		
	var file = FileAccess.open(tile_yaml_path, FileAccess.READ)
	if file:
		var yaml_string = file.get_as_text()
		var result = YAML.parse(yaml_string)
		if !result.has_error():
			tile_defs = result.get_data()
		else:
			print("TileData not loaded: %s" % result.get_error())
	else:
		push_error("Could not load " + tile_yaml_path)

func _ready():
	load_tiles()

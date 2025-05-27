extends TextureRect


@export var tilemap_layer: Node
@export var entities_layer: Node

#@onready var tilemap_layer = $"Node2D/TileMapLayer"
#@onready var entities_layer = $"Node2D/Entities"

var map_data = []
var player_grid_pos = Vector2i.ZERO
var player_facing: int = 0
var entity_positions = []

func set_map_data(data):
	map_data = data
	draw_minimap()
	
func set_player_pos(grid_pos, facing):
	player_grid_pos = grid_pos
	player_facing = facing
	update_entities()
	center_minimap_on_player()
	
func set_entities(entity_list):
	entity_positions = entity_list
	update_entities()
	
func draw_minimap():
	print("Tilemap layer: ", tilemap_layer)
	tilemap_layer.clear()
	var tile_type
	for y in range(map_data.size()):
		for x in range (map_data[0].size()):
			if map_data[y][x] == 0:
				tile_type = Vector2i(1, 0)
			elif map_data[y][x] == 1:
				tile_type = Vector2i(0, 0)
			# var tile_type = map_data[y][x]
			tilemap_layer.set_cell(Vector2i(x, y), 0, tile_type, 0)
			
func center_minimap_on_player():
	var tile_size = tilemap_layer.tile_set.tile_size
	var minimap_size = Vector2(256, 256)
	
	var center_pixel = minimap_size / 2
	var player_pixel_pos = tilemap_layer.map_to_local(player_grid_pos)
	var offset = center_pixel - player_pixel_pos
	
	tilemap_layer.position = offset
	entities_layer.position = offset
	
			
func update_entities():
	for child in entities_layer.get_children():
		child.queue_free()
	
	var player_icon = Sprite2D.new()
	player_icon.texture = preload("res://Assets/player.png")
	player_icon.position = tilemap_layer.map_to_local(player_grid_pos)
	var minimap_facing = player_facing
	if minimap_facing == 1:
		minimap_facing = 3
	elif minimap_facing == 3:
		minimap_facing = 1
	player_icon.rotation_degrees = minimap_facing * 90
	entities_layer.add_child(player_icon)
	
	for ent in entity_positions:
		var icon = Sprite2D.new()
		icon.texture = preload("res://Assets/player.png")
		icon.position = tilemap_layer.map_to_local(ent)
		entities_layer.add_child(icon)

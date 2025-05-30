extends TextureRect


@export var tilemap_layer: Node2D
@export var entities_layer: Node

#@onready var tilemap_layer = $"Node2D/TileMapLayer"
#@onready var entities_layer = $"Node2D/Entities"

var map_data = []
var tile_sprites: Dictionary = {}
var discovered_tiles := {}
var visible_tiles := {}
var player_grid_pos = Vector2i.ZERO
var player_facing: int = 0
var entity_positions = []
var tile_size = 32

func set_map_data(data):
	map_data = data
	
func set_player_pos(grid_pos, facing):
	player_grid_pos = grid_pos
	player_facing = facing
	update_entities()
	center_minimap_on_player()
	
func set_entities(entity_list):
	entity_positions = entity_list
	update_entities()
	
#func refresh_minimap_entities():
	#var enemies = entity_root.get_children().filter(func(e): return e.is_enemy)
	#minimap.set_entities(enemies)
	
func color_from_list(rgb_array: Array) -> Color:
	if rgb_array.size() == 3:
		return Color(rgb_array[0] / 255.0, rgb_array[1] / 255.0, rgb_array[2] / 255.0, 1.0)
	else:
		return Color(1, 0, 1) # The Magenta Error
	
func draw_minimap():
	if map_data.is_empty():
		push_warning("draw_minimap() called but map_data is empty!")
		return
	if discovered_tiles.is_empty():
		push_warning("draw_minimap() called but no discovered tiles!")
		return
	for pos in discovered_tiles.keys():
		var tile_id = map_data[pos.y][pos.x]
		var tile_info = GlobalTileData.tile_defs.get(str(tile_id), null)
		if tile_info == null:
			continue

		var draw_color = color_from_list(tile_info["color"])
		if not visible_tiles.has(pos):
			draw_color *= Color(0.4, 0.4, 0.4)

		# Create sprite if it doesn't exist
		if not tile_sprites.has(pos):
			var dot = Sprite2D.new()
			dot.texture = preload("res://Assets/white_pixel.png")
			dot.scale = Vector2(tile_size, tile_size)
			dot.position = Vector2(pos.x * tile_size, pos.y * tile_size)
			tilemap_layer.add_child(dot)
			tile_sprites[pos] = dot

		# Update sprite color
		tile_sprites[pos].modulate = draw_color
			
func center_minimap_on_player():
	var minimap_size = Vector2(512, 512)
	
	var center_pixel = minimap_size / 2
	var player_pixel_pos = Vector2(player_grid_pos.x * tile_size, player_grid_pos.y * tile_size)
	var offset = center_pixel - player_pixel_pos
	
	tilemap_layer.position = offset
	entities_layer.position = offset
	
func mark_tile_visible(grid_pos: Vector2i):
	discovered_tiles[grid_pos] = true
	visible_tiles[grid_pos] = true
	
func update_entities():
	for child in entities_layer.get_children():
		child.queue_free()
	
	var player_icon = Sprite2D.new()
	player_icon.texture = preload("res://Assets/player.png")
	player_icon.position = Vector2(player_grid_pos.x * tile_size, player_grid_pos.y * tile_size)
	# Rotation bandaid:
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
		icon.position = Vector2(ent.x * tile_size, ent.y * tile_size)
		entities_layer.add_child(icon)

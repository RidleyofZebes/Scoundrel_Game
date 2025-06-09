extends Node3D

@export var player_entity: PackedScene
@export var enemy_entity: PackedScene
@export var minimap_path: NodePath
@onready var tile_root   = $TileRoot
@onready var entity_root = $EntityRoot

# var map = MapGenerator.drunken_walk(2400)
var map = MapGenerator.drunken_forest(2400)
# var map = MapGenerator.void_platform(32) # debug room

var tile_scenes: Dictionary = {}
var spawn_tiles = []
var occupied_tiles: Dictionary = {}
var player : Node3D
var ui : Node = null

func load_dungeon_tiles():
	tile_scenes = {
		0: preload("res://Scenes/Tiles/Dungeon/Dungeon_Wall.tscn"),
		1: preload("res://Scenes/Tiles/Dungeon/Dungeon_Floor.tscn"),
#		2: preload(),
#		3: preload(),
	}
	GlobalTileData.load_tiles("res://Data/Dungeon_Tiles.json")

func load_forest_tiles():
	tile_scenes = {
		0: preload("res://Scenes/Tiles/Forest/Forest_Wall.tscn"),
		1: preload("res://Scenes/Tiles/Forest/Forest_Floor.tscn"),
		2: preload("res://Scenes/Tiles/Forest/Forest_Trees.tscn"),
#		3: preload(),
	}
	GlobalTileData.load_tiles("res://Data/Forest_Tiles.json")

func generate_map():
	spawn_tiles.clear()
	GlobalTileData.load_tiles()
	var tile_pos
	for y in range(map.size()):
		for x in range(map[0].size()):
			var tile_id = map[y][x]
			if tile_scenes.has(tile_id):
				var scene = tile_scenes[tile_id]
				var tile: TileBase = scene.instantiate()
				tile.position = Vector3(x, -0.5, y)
				tile.tile_id = tile_id
				if tile_id == 2:  # Tree cluster tile
					var rng = RandomNumberGenerator.new()
					rng.randomize()
					var rotations = [0, 90, 180, 270]
					var random_angle = rotations[rng.randi_range(0, 3)]
					tile.rotation_degrees.y = random_angle
				tile_root.add_child(tile)
				if tile_id == 1:
					spawn_tiles.append(Vector2i(x, y))
	print("Generated ", spawn_tiles.size(), " floor tiles.")

func spawn_player():
	player = player_entity.instantiate()
	
	var random = RandomNumberGenerator.new()
	random.randomize()

	if spawn_tiles.is_empty():
		push_error("No spawn tiles available! Check generate_map() logic.")
		return	

	var player_spawn = spawn_tiles[random.randi_range(0, spawn_tiles.size() -1)]
	occupied_tiles[player_spawn] = player
	player.grid_x = player_spawn[0]
	player.grid_y = player_spawn[1]
	player.facing = random.randi_range(0, 3)
	player.target_rotation_y = player.facing * 90
	player.rotation_degrees.y = player.target_rotation_y
	player.map = map
	player.vision_mode = 2
	player.ui = ui
	player.position = Vector3(player_spawn[0], 0, player_spawn[1])
	var minimap = get_node(minimap_path)
	player.minimap = minimap
	player.world = self
	entity_root.add_child(player)
	var camera = player.get_node("Camera3D")
	$HoverDetector.set_camera(camera)
	player.setup_light()
	player.call_deferred("reveal_tiles", minimap)
	
func spawn_enemies(n):
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	for i in range(n):
		var e = enemy_entity.instantiate()
		var pick = spawn_tiles[rng.randi_range(0, spawn_tiles.size()-1)]
		if occupied_tiles.has(pick):
			continue
		e.grid_x = pick.x; e.grid_y = pick.y
		e.map = map
		e.facing = rng.randi_range(0, 3)
		e.target_rotation_y = e.facing * 90
		e.position = Vector3(pick.x, 0, pick.y)
		e.is_enemy = true
		e.player = player
		e.world = self
		var enemy_id = GlobalEnemyData.get_random_enemy()
		e.enemy_id = enemy_id
		entity_root.add_child(e)
		occupied_tiles[pick] = e
		e.setup_light()
		
func end_player_turn():
	for child in entity_root.get_children():
		if child.has_method("take_turn"):
			child.active = true
			
func generate_world(map_type: String, steps: int, enemies: int) -> void:
	match map_type:
		"dungeon":
			load_dungeon_tiles()
			map = MapGenerator.drunken_walk(steps)
		"forest":
			load_forest_tiles()
			map = MapGenerator.drunken_forest(steps)
		_:
			push_error("Unknown map type: " + map_type)
			return
			
	generate_map()
	spawn_player()
	spawn_enemies(enemies)
	
	var minimap = get_node(minimap_path)
	minimap.set_map_data(map)
	minimap.set_player_pos(Vector2i(player.grid_x, player.grid_y), player.facing)
	MessageBox.say("You venture forth into the unknown...")
	
func _ready() -> void:
	MessageBox.show()
	generate_world("forest", 2400, 10) # TODO: Take two inputs, map_type and steps

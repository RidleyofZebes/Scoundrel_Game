extends Node3D

@export var player_entity: PackedScene
@export var enemy_entity: PackedScene
@export var minimap_path: NodePath
@export var chest_scene: PackedScene  # Temporary until I figure this out. Can't just have a line for every one of the damned things.
@onready var tile_root   = $TileRoot
@onready var entity_root = $EntityRoot
@onready var loading_screen := $"../../../LoadingScreen"
@onready var UI_root := $"../../../UI"

# var map = MapGenerator.drunken_walk(2400)
# var map = MapGenerator.drunken_forest(2400)
var map
# var map = MapGenerator.void_platform(32) # debug room

var tile_scenes: Dictionary = {}
var spawn_tiles = []
var occupied_tiles: Dictionary = {}
var player : Node3D
var ui : Node = null
var menu_screen: Control = null
var minimap: TextureRect = null
var ui_root: Node = null
var exit_tile: Vector2i = Vector2i(-1, -1)
var entrance_tile: Vector2i = Vector2i(-1, -1)
var player_spawn: Vector2i = Vector2i(-1, -1)

func load_dungeon_tiles():
	tile_scenes = {
		0: preload("res://Scenes/Tiles/Dungeon/Dungeon_Wall.tscn"),
		1: preload("res://Scenes/Tiles/Dungeon/Dungeon_Floor.tscn"),
#		2: preload(), # Void
		3: preload("res://Scenes/Tiles/Dungeon/Dungeon_Door.tscn"),
		4: preload("res://Scenes/Tiles/Dungeon/Dungeon_Entrance.tscn"),
		5: preload("res://Scenes/Tiles/Dungeon/Dungeon_Exit.tscn"),
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
	
func get_door_rotation(x: int, y: int) -> float:
	var north = map[y-1][x] if y > 0 else -1
	var south = map[y+1][x] if y < map.size()-1 else -1
	var west  = map[y][x-1] if x > 0 else -1
	var east  = map[y][x+1] if x < map.size()-1 else -1
	
	var north_south = (north == 1 or south == 1)
	var east_west = (east == 1 or west == 1)
	
	if east_west and not north_south:
		return 90.0
	return 0.0
	
func get_entrance_rotation(entrance: Vector2i, floor: Vector2i) -> float:
	var dir = floor - entrance  # Vector2i
	var rot
	if dir == Vector2i(0, 1):   # floor is south of entrance
		rot = 0.0
	elif dir == Vector2i(0, -1): # floor is north of entrance
		rot = 180.0
	elif dir == Vector2i(1, 0):  # floor is east of entrance
		rot = 90.0
	elif dir == Vector2i(-1, 0): # floor is west of entrance
		rot = 270.0
	return rot
	
func random_rotate():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var rotations = [0, 90, 180, 270]
	var random_angle = rotations[rng.randi_range(0, 3)]
	return random_angle
	
func generate_map():
	spawn_tiles.clear()
	GlobalTileData.load_tiles()
	
	var entrance_node : TileBase = null
	entrance_tile = Vector2i(-1, -1)
	exit_tile = Vector2i(-1, -1)
	player_spawn = Vector2i(-1, -1)
	
	for y in range(map.size()):
		for x in range(map[0].size()):
			var tile_id = map[y][x]
			if tile_scenes.has(tile_id):
				var scene = tile_scenes[tile_id]
				var tile: TileBase = scene.instantiate()
				
				tile.position = Vector3(x, -0.5, y)
				tile.tile_id = tile_id
				tile_root.add_child(tile)
				
				if tile_id == 1: # floor tiles
					spawn_tiles.append(Vector2i(x, y))
				
				if tile_id == 2: # special wall tiles
					tile.rotation_degrees.y = random_rotate()
				
				if tile_id == 3: # doors
					var rot = get_door_rotation(x, y)
					tile.rotation_degrees.y = rot
					tile.grid_x = x
					tile.grid_y = y
					
				if tile_id == 4: # entrance
					entrance_tile = Vector2i(x, y)
					entrance_node = tile
					
				if tile_id == 5: # exit
					exit_tile = Vector2i(x, y)
					
	if entrance_tile != Vector2i(-1, -1):
		var dirs = [Vector2i(0,1), Vector2i(1,0), Vector2i(0,-1), Vector2i(-1,0)]
		for dir in dirs:
			var check = entrance_tile + dir
			if check.x >= 0 and check.x < map[0].size() and check.y >= 0 and check.y < map.size():
				if map[check.y][check.x] == 1:
					player_spawn = check
					break
				
	if entrance_node:
			entrance_node.rotation_degrees.y = get_entrance_rotation(entrance_tile, player_spawn)
					
	if spawn_tiles.has(entrance_tile):
		spawn_tiles.erase(entrance_tile)
	if spawn_tiles.has(exit_tile):
		spawn_tiles.erase(exit_tile)
					
	print("Generated ", spawn_tiles.size(), " floor tiles.")

func spawn_player():
	player = player_entity.instantiate()
	
	if entrance_tile == Vector2i(-1, -1) or player_spawn == Vector2i(-1, -1):
		push_error("No entrance or spawn tile set! Check your generation logic, dumbass.")
		return
	
	occupied_tiles[entrance_tile] = player
	player.grid_x = player_spawn.x
	player.grid_y = player_spawn.y
	player.facing = 2
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
	GameState.player = player
	var camera = player.get_node("Camera3D")
	$HoverDetector.set_camera(camera)
	player.setup_light()
	player.call_deferred("reveal_all_minimaps")
	
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
		e.add_to_group("enemies")
		e.world = self
		var enemy_id = GlobalEnemyData.get_random_enemy()
		e.enemy_id = enemy_id
		entity_root.add_child(e)
		occupied_tiles[pick] = e
		e.setup_light()
		
func spawn_chests(amount: int = 5):
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	for i in range(amount):
		var chest = chest_scene.instantiate()
		
		var pos: Vector2i = spawn_tiles[rng.randi_range(0, spawn_tiles.size() - 1)]
		if occupied_tiles.has(pos):
			continue
			
		chest.position = Vector3(pos.x, 0, pos.y)
		chest.grid_x = pos.x
		chest.grid_y = pos.y
		occupied_tiles[pos] = chest
		tile_root.add_child(chest)
		
func end_player_turn():
	for child in entity_root.get_children():
		if child.has_method("take_turn"):
			child.active = true
	await get_tree().process_frame
	update_minimap_entities()
			
func update_minimap_entities():
	var visible_positions = []
	var minimap = get_node(minimap_path)
	var visible = minimap.visible_tiles.keys()
	
	for e in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(e) or e.get_parent() == null:
			continue
		var pos = Vector2i(e.grid_x, e.grid_y)
		if visible.has(pos):
			visible_positions.append(pos)
	
	minimap.set_entities(visible_positions)
	
	if GameState.menu_minimap:
		GameState.menu_minimap.set_entities(visible_positions)
			
func generate_world(map_type: String, variant: String, steps: int, enemies: int) -> void:
	var env_resource: Environment
	match variant:
		"sunny":
			env_resource = preload("res://Scenes/Environments/Sunny.tres")
		"moonlit":
			env_resource = preload("res://Scenes/Environments/Moonlit.tres")
		"pitchblack":
			env_resource = preload("res://Scenes/Environments/Pitchblack.tres")
		_:
			push_warning("Unknown environment, using default!")
			env_resource = preload("res://Scenes/Environments/Pitchblack.tres")
			
	load_dungeon_tiles()
	map = MapGenerator.generate_map(map_type, steps)
			
	$WorldEnvironment.environment = env_resource
	generate_map()
	spawn_player()
	spawn_enemies(enemies)
	spawn_chests(5)
	
	var minimap = get_node(minimap_path)
	minimap.set_map_data(map)
	minimap.set_player_pos(Vector2i(player.grid_x, player.grid_y), player.facing)
	GameState.menu_minimap.set_map_data(map)
	GameState.menu_minimap.set_player_pos(Vector2i(player.grid_x, player.grid_y), player.facing)
	update_minimap_entities()
	MessageBox.say("You venture forth into the unknown...")
	
func toggle_loading_screen(show: bool):
	if loading_screen:
		loading_screen.visible = show
		if show:
			loading_screen.move_to_front()
			
	UI_root.visible = not show
	
func _ready() -> void:
	GameState.world = self
	toggle_loading_screen(true)
	await get_tree().process_frame
	generate_world("dungeon", "pitchblack", 50, 10)
	toggle_loading_screen(false)
	MessageBox.show()
	
func reveal_all_entities():
	var all_entity_positions := []
	for e in get_tree().get_nodes_in_group("enemies"):
		if is_instance_valid(e) and e.get_parent() != null:
			all_entity_positions.append(Vector2i(e.grid_x, e.grid_y))
	var minimap = get_node_or_null(minimap_path)
	if minimap:
		minimap.set_entities(all_entity_positions)
	if GameState.menu_minimap:
		GameState.menu_minimap.set_entities(all_entity_positions)

extends Node3D

@export var floor_tile: PackedScene
@export var wall_tile:  PackedScene
@export var water_tile: PackedScene
@export var player_entity: PackedScene
@export var enemy_entity: PackedScene
@export var minimap_path: NodePath
@onready var tile_root   = $TileRoot
@onready var entity_root = $EntityRoot

var map = MapGenerator.drunken_walk(2400)
# var map = MapGenerator.void_platform(32) # debug room
var spawn_tiles = []
var player : Node3D
var ui : Node = null

func generate_map():
	spawn_tiles.clear()
	var tile_pos
	var scene
	for y in range(map.size()):
		for x in range(map[0].size()):
			if map[y][x] == 0:
				scene = wall_tile
				tile_pos = Vector3(x, 0, y)
			elif map[y][x] == 1:
				scene = floor_tile
				tile_pos = Vector3(x, -0.5, y)
				spawn_tiles.append(Vector2i(x, y))
			elif map[y][x] == 2: # Water tile for later
				pass
			var tile = scene.instantiate()
			tile.position = tile_pos
			tile_root.add_child(tile)

func spawn_player():
	player = player_entity.instantiate()
	
	var random = RandomNumberGenerator.new()
	random.randomize()
	
	var player_spawn = spawn_tiles[random.randi_range(0, spawn_tiles.size() -1)]
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
	
	player.setup_light()
	player.call_deferred("reveal_tiles", minimap)
	
func spawn_enemies(n):
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	for i in range(n):
		var e = enemy_entity.instantiate()
		var pick = spawn_tiles[rng.randi_range(0, spawn_tiles.size()-1)]
		e.grid_x = pick.x; e.grid_y = pick.y
		e.map = map
		e.facing = rng.randi_range(0, 3)
		e.target_rotation_y = e.facing * 90
		e.position = Vector3(pick.x, 0, pick.y)
		e.is_enemy = true
		e.player = player
		var enemy_id = GlobalEnemyData.get_random_enemy()
		e.enemy_id = enemy_id
		entity_root.add_child(e)
		e.setup_light()
		
func end_player_turn():
	for child in entity_root.get_children():
		if child.has_method("take_turn"):
			child.active = true
	

func _ready() -> void:
	MessageBox.show()
	generate_map() # TODO: Take two inputs, map_type and steps
	spawn_player()
	spawn_enemies(10)
	var minimap = get_node(minimap_path)
	print(minimap)
	minimap.set_map_data(map)
	minimap.set_player_pos(Vector2i(player.grid_x, player.grid_y), player.facing)
	MessageBox.say("You venture forth into the unknown...")
	#minimap.set_entity_positions(get_tree().get_node("Main/EntityRoot").get_children().filter(is_enemy))

## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass

extends Node3D

@export var floor_tile: PackedScene
@export var wall_tile:  PackedScene
@export var water_tile: PackedScene
@export var player_entity: PackedScene
@onready var tile_root   = $TileRoot
@onready var entity_root = $EntityRoot

var map = MapGenerator.drunken_walk(2400)
var spawn_tiles = []

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
	var player = player_entity.instantiate()
	
	var random = RandomNumberGenerator.new()
	random.randomize()
	var player_spawn = spawn_tiles[random.randi_range(0, spawn_tiles.size() -1)]
	player.grid_x = player_spawn[0]
	player.grid_y = player_spawn[1]
	player.facing = random.randi_range(0, 3)
	player.target_rotation_y = player.facing * 90
	player.rotation_degrees.y = player.target_rotation_y
	player.map = map
	player.position = Vector3(player_spawn[0], 0, player_spawn[1])
	entity_root.add_child(player)
	

func _ready() -> void:
	generate_map() # TODO: Take two inputs, map_type and steps
	spawn_player()

## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass

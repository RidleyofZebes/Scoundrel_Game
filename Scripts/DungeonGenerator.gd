extends Node


var recipe = {
	"type": "classic",
	"num_rooms": 8,
	"room_min_size": 4,
	"room_max_size": 8,
	"caves": false,
	"bsp": true,
	"corridor_type": "straight",
	"prefab_rooms": [],
	"theme": "dungeon"
	}
	
func generate(width: int, height: int, recipe_override: Dictionary = {}) -> Dictionary:
	var cfg = recipe.duplicate()
	for k in recipe_override.keys():
		cfg[k] = recipe_override[k]
		
	var map = []
	for y in range(height):
		var row = []
		for x in range(width):
			row.append(0)
		map.append(row)
		
	if cfg["bsp"]:
		map = generate_bsp_rooms(map, cfg)
	#if cfg["caves"]:
		#map = carve_caves(map, cfg)
			
	map = carve_corridors(map, cfg)
	map = place_doors(map, cfg)
	map = place_entrance_exit(map, cfg)
	
	return map
	
func generate_bsp_rooms(map: Array, cfg: Dictionary) -> Array:
	var width = map[0].size()
	var height = map.size()
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	for i in range (cfg["num_rooms"]):
		var rw = rng.randi_range(cfg["room_min_size"], cfg["room_max_size"])
		var rh = rng.randi_range(cfg["room_min_size"], cfg["room_max_size"])
		var rx = rng.randi_range(1, width - rw - 2)
		var ry = rng.randi_range(1, height - rh - 2)
		
		for y in range(ry, ry + rh):
			for x in range(rx, rx + rw):
				map[y][x] = 1
				
	return map
	
func carve_corridors(map: Array, cfg: Dictionary) -> Array:
	var width = map[0].size()
	var height = map.size()
	var room_centers = []
	
	for y in range (1, height - 1):
		for x in range(1, width - 1):
			if map[y][x] == 1:
				if map[y - 1][x] == 1 and map[y + 1][x] == 1 and map[y][x - 1] == 1 and map[y][x + 1] == 1:
					room_centers.append(Vector2i(x, y))
					
	for i in range(room_centers.size() - 1):
		var a = room_centers[i]
		var b = room_centers[i + 1]
		for x in range(min(a.x, b.x), max(a.x, b.x) + 1):
			map[a.y][x] = 1
		for y in range(min(a.y, b.y), max(a.y, b.y) + 1):
			map[y][b.x] = 1
			
	return map
	
func place_doors(map: Array, cfg: Dictionary) -> Array:
	var width = map[0].size()
	var height = map.size()
	
	for y in range(1, height - 1):
		for x in range(1, width - 1):
			if map[y][x] == 1:
				if map[y][x - 1] == 1 and map[y][x + 1] == 1 and map[y - 1][x] == 0 and map[y + 1][x] == 0:
					map[y][x] = 3
					
	return map
	
func find_entrance_candidates(map):
	var width = map[0].size()
	var height = map.size()
	var candidates = []
	for y in range(1, height - 1):
		for x in range(1, width - 1):
			if map[y][x] == 0:
				var dirs = [Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0)]
				for dir in dirs:
					var nx = x + dir.x
					var ny = y + dir.y
					# Ensure adjacent floor isn't on the edge
					if nx > 0 and nx < width - 1 and ny > 0 and ny < height - 1:
						if map[ny][nx] == 1:
							candidates.append({
								"pos": Vector2i(x, y),
								"adj": Vector2i(nx, ny),
								"dir": dir
							})
							break
	return candidates
	
func place_entrance_exit(map, cfg):
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var candidates = find_entrance_candidates(map)
	if candidates.size() == 0:
		push_error("No valid entrance candidates found.")
		return {}
	var chosen = candidates[rng.randi_range(0, candidates.size() - 1)]
	var entrance_pos = chosen["pos"]
	var player_spawn = chosen["adj"]
	var entrance_dir = chosen["dir"]

	map[entrance_pos.y][entrance_pos.x] = 4 # Mark entrance

	# Gather all floor tiles for possible exits
	var all_floors = []
	var width = map[0].size()
	var height = map.size()
	for y in range(height):
		for x in range(width):
			if map[y][x] == 1:
				all_floors.append(Vector2i(x, y))
				
	# Pick exit far enough from player spawn (e.g., manhattan distance >= threshold)
	var exit_tile = null
	var min_dist = 10
	var attempts = 100
	while attempts > 0:
		var candidate = all_floors[rng.randi_range(0, all_floors.size() - 1)]
		var dist = abs(candidate.x - player_spawn.x) + abs(candidate.y - player_spawn.y)
		if dist >= min_dist:
			exit_tile = candidate
			break
		attempts -= 1
	# If no distant exit found, just pick any
	if exit_tile == null and all_floors.size() > 0:
		exit_tile = all_floors[rng.randi_range(0, all_floors.size() - 1)]

	if exit_tile != null:
		map[exit_tile.y][exit_tile.x] = 5 # Mark exit

	return {
		"map": map,
		"player_spawn": player_spawn,
		"entrance_tile": entrance_pos,
		"entrance_dir": entrance_dir,
		"exit_tile": exit_tile
	}

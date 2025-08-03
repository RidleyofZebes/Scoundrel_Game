extends Node

func void_platform(radius):
	var map := []
	for y in range(radius):
		var row := []
		for x in range (radius):
			row.append(1)
		map.append(row)
	return map
	

func drunken_walk(step_target: int) -> Array:
	# We'll return a 2D grid with the path marked as 1
	var map := []
	var coords := [Vector2i(0, 0)]
	
	var x := 0
	var y := 0
	var tiles_covered := 0
	
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	
	while tiles_covered < step_target - 1:
		var direction = rng.randi_range(0, 3)
		match direction:
			0: y += 1	# north
			1: x += 1	# east
			2: y -= 1	# south
			3: x -= 1	# west
		
		var new_coord = Vector2i(x, y)
		var add_coords = true
		for c in coords:
			if c == new_coord:
				add_coords = false
				break
		if add_coords:
			coords.append(new_coord)
			tiles_covered += 1
	
	# Find min/max for grid sizing
	var x_vals := coords.map(func(p): return p.x)
	var y_vals := coords.map(func(p): return p.y)
	var min_x = x_vals.min()
	var max_x = x_vals.max()
	var min_y = y_vals.min()
	var max_y = y_vals.max()
	
	var grid_width = abs(min_x) + abs(max_x) + 3
	var grid_height = abs(min_y) + abs(max_y) + 3
	
	# Initialize grid
	for y_ in range(grid_height):
		map.append([])
		for x_ in range(grid_width):
			map[y_].append(0)
	
	# Offset all points so they fit in the grid
	for p in coords:
		var new_x = p.x + abs(min_x) + 1
		var new_y = p.y + abs(min_y) + 1
		map[new_y][new_x] = 1
	
	return map
	
func drunken_forest(step_target: int) -> Array:
	var base_map = drunken_walk(step_target)

	var height = base_map.size()
	var width = base_map[0].size()
	var padded_map = []
	
	var row = []
	row.resize(width + 2)
	row.fill(0)
	padded_map.append(row)
	
	for y in range(height):
		var new_row = []
		new_row.append(0)
		for x in range(width):
			new_row.append(base_map[y][x])
		new_row.append(0)
		padded_map.append(new_row)
	
	var padded_height = padded_map.size()
	var padded_width = padded_map[0].size()
	
	for y in range(padded_height):
		for x in range(padded_width):
			if padded_map[y][x] != 0:
				continue
				
			for dy in range(-1, 2):
				for dx in range(-1, 2):
					var ny = y + dy
					var nx = x + dx

					if ny < 0 or ny >= padded_height or nx < 0 or nx >= padded_width:
						continue

					if padded_map[ny][nx] == 1:
						padded_map[y][x] = 2
						break

	return padded_map


func simple_maze(width: int, height: int) -> Array:
	if width % 2 == 0:
		width += 1
	if height % 2 == 0:
		height += 1

	var maze = []
	for y in range(height):
		maze.append([])
		for x in range(width):
			maze[y].append(0)

	var directions = [Vector2i(0,-2), Vector2i(0,2), Vector2i(2,0), Vector2i(-2,0)]
	var rng = RandomNumberGenerator.new()
	rng.randomize()

	var stack = [Vector2i(1,1)]
	maze[1][1] = 1

	while stack.size() > 0:
		var pos = stack.back()
		directions.shuffle()
		var carved = false

		for dir in directions:
			var next_pos = pos + dir
			if next_pos.x > 0 and next_pos.x < width - 1 and next_pos.y > 0 and next_pos.y < height - 1 and maze[next_pos.y][next_pos.x] == 0:
				maze[pos.y + dir.y / 2][pos.x + dir.x / 2] = 1
				maze[next_pos.y][next_pos.x] = 1
				stack.append(next_pos)
				carved = true
				break

		if not carved:
			stack.pop_back()

	return maze

func roomy_maze(width: int, height: int, room_attempts: int = 10, room_min: int = 3, room_max: int = 7) -> Array:
	var maze = simple_maze(width, height)
	var rng = RandomNumberGenerator.new()
	rng.randomize()

	for i in range(room_attempts):
		var room_w = rng.randi_range(room_min, room_max)
		var room_h = rng.randi_range(room_min, room_max)
		var room_x = rng.randi_range(1, width - room_w - 2)
		var room_y = rng.randi_range(1, height - room_h - 2)

		if room_x % 2 == 0:
			room_x += 1
		if room_y % 2 == 0:
			room_y += 1

		for y in range(room_y, room_y + room_h):
			for x in range(room_x, room_x + room_w):
				maze[y][x] = 1

	return maze

#########################################
### 2.0 DUNGEON GENERATOR STARTS HERE ###
#########################################

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
	
func generate_dungeon(width: int, height: int, recipe_override: Dictionary = {}) -> Array:
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
			if map[y][x] != 1:
				continue
				
			if map[y][x-1] == 1 and map[y][x+1] == 1 and map[y-1][x] == 0 and map[y+1][x] == 0:
				if map[y-1][x-1] == 1 or map[y-1][x+1] == 1 or map[y+1][x-1] == 1 or map[y+1][x+1] == 1:
					map[y][x] = 3
			elif map[y-1][x] == 1 and map[y+1][x] == 1 and map[y][x-1] == 0 and map[y][x+1] == 0:
				if map[y-1][x-1] == 1 or map[y+1][x-1] == 1 or map[y-1][x+1] == 1 or map[y+1][x+1] == 1:
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
	
func place_entrance_exit(map: Array, cfg: Dictionary) -> Array:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var candidates = find_entrance_candidates(map)
	if candidates.size() == 0:
		push_error("No valid entrance candidates found.")
		return map
	var chosen = candidates[rng.randi_range(0, candidates.size() - 1)]
	var entrance_pos = chosen["pos"]

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
		var dist = abs(candidate.x - entrance_pos.x) + abs(candidate.y - entrance_pos.y)
		if dist >= min_dist:
			exit_tile = candidate
			break
		attempts -= 1
	# If no distant exit found, just pick any
	if exit_tile == null and all_floors.size() > 0:
		exit_tile = all_floors[rng.randi_range(0, all_floors.size() - 1)]

	if exit_tile != null:
		map[exit_tile.y][exit_tile.x] = 5 # Mark exit

	return map

###############################
### Final Product Generator ###
###############################

func generate_map(map_type: String, size: int) -> Array:
	var map
	match map_type:
		"dungeon":
			map = generate_dungeon(size, size)
		"forest":
			map = drunken_forest(size)
		"maze":
			map = simple_maze(size, size)
		"void":
			map = void_platform(size)
		_:
			push_error("Check the requested map type, what the fuck even is a %s??!" % map_type)
			map = []
	map = place_entrance_exit(map, {})
	return map
		

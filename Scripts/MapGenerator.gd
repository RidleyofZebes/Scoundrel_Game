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

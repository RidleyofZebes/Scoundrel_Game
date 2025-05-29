extends "res://Scripts/EntityBase.gd"

## Works, but is wrong?
var direction_vectors = [
	Vector2i(0, -1),  # N
	Vector2i(-1, 0),  # E
	Vector2i(0, 1),   # S
	Vector2i(1, 0)    # W
]
var minimap: Node = null
var input_held := false
var input_direction := Vector2i.ZERO
var input_repeat_timer := 0.0
var input_repeat_delay := 0.4
var input_repeat_rate := 0.1

func _process(delta):		
	var dir = Vector2i.ZERO
	
	if   Input.is_action_pressed("move_forward"):
		dir = direction_vectors[facing]
	elif Input.is_action_pressed("move_backward"):
		dir = direction_vectors[(facing + 2) % 4]
	elif Input.is_action_pressed("strafe_left"):
		dir = direction_vectors[(facing + 1) % 4]
	elif Input.is_action_pressed("strafe_right"):
		dir = direction_vectors[(facing + 3) % 4]
		
	if dir != Vector2i.ZERO:
		if not input_held:
			input_held = true
			input_direction = dir
			input_repeat_timer = input_repeat_delay

			if not moving:
				if try_move(dir.x, dir.y):
					reveal_tiles(minimap)
		else:
			input_repeat_timer -= delta
			if input_repeat_timer <= 0:
				if not moving:
					if try_move(input_direction.x, input_direction.y):
						reveal_tiles(minimap)
					input_repeat_timer = input_repeat_rate
	else:
		input_held = false
		input_repeat_timer = 0
		
func _unhandled_input(event):
	if event.is_action_pressed("turn_left"):
		turn(1)
		reveal_tiles(minimap)
	elif event.is_action_pressed("turn_right"):
		turn(-1)
		reveal_tiles(minimap)
		
func get_line(x0: int, y0: int, x1: int, y1: int) -> Array:
	var line = []
	var dx = abs(x1 - x0)
	var dy = -abs(y1 - y0)
	var sx = 1 if x0 < x1 else -1
	var sy = 1 if y0 < y1 else -1
	var err = dx + dy
	var x = x0
	var y = y0

	while true:
		line.append(Vector2i(x, y))
		if x == x1 and y == y1:
			break
		var e2 = 2 * err
		if e2 >= dy:
			err += dy
			x += sx
		if e2 <= dx:
			err += dx
			y += sy

	return line

func reveal_tiles(minimap):
	minimap.visible_tiles.clear()
	var vision_range = 6
	match vision_mode:
		VisionMode.BLIND: 
			vision_range = 0
		VisionMode.DARKVISION: 
			vision_range = 8
		VisionMode.TORCH: 
			vision_range = 4
		VisionMode.LANTERN: 
			vision_range = 6
		VisionMode.BULLSEYE: 
			vision_range = 8
		

	var origin = Vector2i(grid_x, grid_y)

	for y in range(grid_y - vision_range, grid_y + vision_range + 1):
		for x in range(grid_x - vision_range, grid_x + vision_range + 1):
			var target = Vector2i(x, y)

			if target.x < 0 or target.x >= map[0].size() or target.y < 0 or target.y >= map.size():
				continue

			if origin.distance_to(target) > vision_range:
				continue

			if vision_mode == VisionMode.BULLSEYE:
				var dir = Vector2(direction_vectors[facing]).normalized()
				var to_tile = Vector2(target - origin).normalized()
				if dir.dot(to_tile) < 0.7:
					continue

			for pos in get_line(grid_x, grid_y, x, y):
				if pos.x < 0 or pos.x >= map[0].size() or pos.y < 0 or pos.y >= map.size():
					break

				if map[pos.y][pos.x] == 0:
					minimap.mark_tile_visible(pos)
					break

				minimap.mark_tile_visible(pos)
				
	minimap.draw_minimap()

extends "res://Scripts/EntityBase.gd"


## Works, but is wrong?
var direction_vectors = [
	Vector2i(0, -1),  # N
	Vector2i(-1, 0),  # E
	Vector2i(0, 1),   # S
	Vector2i(1, 0)    # W
]
#var entity_type := 1
var minimap: Node = null
var input_held := false
var input_direction := Vector2i.ZERO
var input_repeat_timer := 0.0
var input_repeat_delay := 0.4
var input_repeat_rate := 0.1
var display_name: String = "You"
var inventory := Inventory.new()

var stats := {
	"Luck": 5,
	"Charm": 5,
	"Wit": 5,
	"Brawn": 5,
	"Edge": 5,
	"Grit": 5
}

func _ready():
	entity_type = 1

func get_stat(stat_name: String) -> int:
	return stats.get(stat_name, 0)

func _process(delta):
	if GameState.menu_type != GameState.MenuType.NONE:
		return
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
					reveal_all_minimaps()
					update_minimap_pos()
					world.end_player_turn()
		else:
			input_repeat_timer -= delta
			if input_repeat_timer <= 0:
				if not moving:
					if try_move(input_direction.x, input_direction.y):
						reveal_all_minimaps()
						update_minimap_pos()
						world.end_player_turn()
					input_repeat_timer = input_repeat_rate
	else:
		input_held = false
		input_repeat_timer = 0
		
func _unhandled_input(event):
	if GameState.menu_type != GameState.MenuType.NONE:
		return
	if   event.is_action_pressed("turn_left"):
		turn(1)
		reveal_all_minimaps()
	elif event.is_action_pressed("turn_right"):
		turn(-1)
		reveal_all_minimaps()
	elif event.is_action_pressed("attack"):
		attack()
	elif event.is_action_pressed("examine"):
		examine()
	elif event.is_action_pressed("interact"):
		interact()
		
func reveal_all_minimaps():
	for mm in [minimap, GameState.menu_minimap]:
		if mm:
			reveal_tiles(mm)
			GameState.menu_minimap.set_player_pos(Vector2i(grid_x, grid_y), facing)
		
func attack():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var base = rng.randi_range(1, 6) #1d6 damage hardcoded for now, no weapons to calculate from yet.
	var bonus = get_stat("Brawn") / 2
	var damage = base + bonus
	var is_crit = rng.randi_range(1, 100) <= get_stat("Luck") * 2
	if is_crit:
		damage *= 2
		MessageBox.say("Critical hit!")
	
	var dir = direction_vectors[facing]
	var target_x = grid_x + dir.x
	var target_y = grid_y + dir.y
	
	if target_y < 0 or target_y >= map.size() or target_x < 0 or target_x >= map[0].size():
		print("Attack out of bounds!")
		return
		
	for ent in world.entity_root.get_children():
		if ent != self and ent.has_method("take_damage") and ent.grid_x == target_x and ent.grid_y == target_y:
			print("Player attacks ", ent.name, " at ", target_x, ", ", target_y)
			MessageBox.say("You attack the %s for %d damage!" % [ent.display_name, damage])
			ent.take_damage(damage)
			if ent.health <=0:
				MessageBox.say("The %s is slain!" % ent.display_name)
			world.end_player_turn()
			return
			
	print("No target to attack.")
	
func examine():
	var dir = direction_vectors[facing]
	var target_pos = Vector2i(grid_x + dir.x, grid_y + dir.y)
	
	for entity in get_tree().get_nodes_in_group("entities"):
		if entity.grid_x == target_pos.x and entity.grid_y == target_pos.y:
			print("Found match:", entity.name) 
			if entity.examine_text != "":
				MessageBox.say(entity.examine_text)
				return
			else:
				MessageBox.say(entity.display_name)
				return
	if target_pos.y >= 0 and target_pos.y < map.size() and target_pos.x >= 0 and target_pos.x < map[0].size():
		var tile_id = str(map[target_pos.y][target_pos.x])
		var tile_data = GlobalTileData.tile_defs.get(tile_id, null)
		if tile_data and tile_data.has("examine"):
			MessageBox.say(tile_data["examine"])
			return
			
	MessageBox.say("There's nothing there, except for... No, no, there's nothing.")
	
func interact():
	var dir = direction_vectors[facing]
	var target_pos = Vector2i(grid_x + dir.x, grid_y + dir.y)
	
	for entity in get_tree().get_nodes_in_group("entities"):
		if entity.grid_x == target_pos.x and entity.grid_y == target_pos.y:
			if entity.has_method("interact"):
				entity.interact(Vector2i(grid_x, grid_y))
			return
	MessageBox.say("You see nothing of interest.")
	
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

				var tile_id = map[pos.y][pos.x]
				var tile_data = GlobalTileData.tile_defs.get(str(tile_id), {})
				
				if tile_data.isWall == 1 or tile_data.isWall == 3:
					minimap.mark_tile_visible(pos)
					break

				minimap.mark_tile_visible(pos)
				
	minimap.draw_minimap()

func update_minimap_pos():
	minimap.set_player_pos(Vector2i(grid_x, grid_y), facing)

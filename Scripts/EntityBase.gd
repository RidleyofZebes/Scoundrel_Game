extends Node3D


var grid_x: int
var grid_y: int
var health: int = 10
var map: Array = []
var facing: int  # 0=N, 1=E, 2=S, 3=W
var target_rotation_y = 0.0
var move_duration: float = 0.2  # seconds to move one tile
var move_elapsed: float = 0.0
var start_position: Vector3
var end_position: Vector3
var moving: bool = false

func try_move(dx: int, dy: int) -> bool:
	if moving:
		return false
	
	var new_x = grid_x + dx
	var new_y = grid_y + dy
	if new_y < 0 or new_y >= map.size() or new_x < 0 or new_x >= map[0].size():
		print("can't move to ", new_x, " ", new_y, "!")
		return false
	if map[new_y][new_x] != 1:
		print("can't move!")
		return false
		
	grid_x = new_x
	grid_y = new_y
	start_position = position
	end_position = Vector3(grid_x, 0, grid_y)
	move_elapsed = 0.0
	moving = true
	print("→ Moving from ", start_position, " to ", end_position)

	return true
	
func turn(direction):
	facing = (facing + direction) % 4
	if facing < 0:
		facing += 4
	target_rotation_y = facing * 90.0
	print("Now facing: ", facing)
	
func take_damage(amount):
	health -= amount
	if health <= 0:
		die()

func die():
	queue_free()

func _process(delta):
	# Smooth rotation
	const TURN_SPEED := 360
	
	var diff = wrapf(target_rotation_y - rotation_degrees.y + 180.0, 0.0, 360.0) - 180.0
	var step = TURN_SPEED * delta
	if abs(diff) <= step:
		rotation_degrees.y = target_rotation_y
	else:
		rotation_degrees.y += sign(diff) * step

#	rotation_degrees.y = target_rotation_y # Snap rotation fallback

	# Smoothe move, Exlax
	if moving:
		move_elapsed += delta
		var t = clamp(move_elapsed / move_duration, 0.0, 1.0)
		
		global_position = start_position.lerp(end_position, t)
		
		if t >= 1.0:
			t = 1.0
			moving = false

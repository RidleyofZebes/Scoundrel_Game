extends "res://Scripts/EntityBase.gd"

## Works, but is wrong?
var direction_vectors = [
	Vector2i(0, -1),  # N
	Vector2i(-1, 0),  # E (was 1,0; now -1,0)
	Vector2i(0, 1),   # S
	Vector2i(1, 0)    # W (was -1,0; now 1,0)
]

func _unhandled_input(event):
	if moving:
		return
	if   event.is_action_pressed("move_forward"):
		var vec = direction_vectors[facing]
		try_move(vec.x, vec.y)
	elif event.is_action_pressed("move_backward"):
		var vec = direction_vectors[(facing + 2) % 4]  # Opposite direction
		try_move(vec.x, vec.y)
	elif event.is_action_pressed("strafe_left"):
		var vec = direction_vectors[(facing + 1) % 4]  # 90° left of facing
		try_move(vec.x, vec.y)
	elif event.is_action_pressed("strafe_right"):
		var vec = direction_vectors[(facing + 3) % 4]  # 90° right of facing
		try_move(vec.x, vec.y)
	elif event.is_action_pressed("turn_left"):
		turn(1)
	elif event.is_action_pressed("turn_right"):
		turn(-1)

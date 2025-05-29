extends "res://Scripts/EntityBase.gd"

var active := false

func _ready():
	pass

func take_turn():
	if moving: return
	
	if not player:
		print("Enemy has no player reference!")
		return
			
	var dx = player.grid_x - grid_x
	var dy = player.grid_y - grid_y
	var dist = abs(dx) + abs(dy)
	
	if dist == 1:
		print("Enemy Attacks!")
		player.take_damage(1)
		return
	
	var move_dir := Vector2i.ZERO
	if abs(dx) > abs(dy):
		move_dir.x = sign(dx)
	else:
		move_dir.y = sign(dy)
		
	if try_move(move_dir.x, move_dir.y):
		print("Enemy moves toward player.")
	else:
		print("Enemy failed to move.")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if active:
		print("Enemy taking turn...")
		take_turn()
		active = false

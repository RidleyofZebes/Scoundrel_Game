extends TileBase

@onready var animation_player := $blockbench_export/AnimationPlayer

var is_open = false
var grid_x: int = 0
var grid_y: int = 0
var map = GameState.world.map
var display_name = "d00r"
var last_open_anim: String = ""

func _ready() -> void:
	add_to_group("entities")
	var anim = ""
	if is_open:
		anim = "Open_Out"
		last_open_anim = "anim"
	else:
		anim = "Close_Out"
	if animation_player.has_animation(anim):
		animation_player.play(anim)
		if is_open:
			animation_player.seek(animation_player.current_animation_length, true)
		else:
			animation_player.seek(0, true)
	
func interact(interact_origin: Vector2i):
	var delta = interact_origin - Vector2i(grid_x, grid_y)
	var anim = ""

	var horizontal = abs(delta.x) > abs(delta.y)
	if is_open:
		if last_open_anim == "Open_In":
			anim = "Close_In"
		else:
			anim = "Close_Out"
	else:
		if horizontal:
			if delta.x < 0:
				anim = "Open_Out"
			else:
				anim = "Open_In"
		else:
			if delta.y < 0:
				anim = "Open_Out"
			else:
				anim = "Open_In"
		last_open_anim = anim 

	is_open = !is_open
	update_tile_state(anim)
	
func update_tile_state(anim_name: String):
	if is_open:
		map[grid_y][grid_x] = 6
	else:
		map[grid_y][grid_x] = 3
	if animation_player.has_animation(anim_name):
		animation_player.play(anim_name)
		print("Playing ", anim_name)
		await animation_player.animation_finished
	
	var player = GameState.player
	if player:
		player.reveal_tiles(player.minimap)

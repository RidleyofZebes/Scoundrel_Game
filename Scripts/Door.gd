extends TileBase

@onready var animation_player := $blockbench_export/AnimationPlayer

var is_open = false
var grid_x: int = 0
var grid_y: int = 0
var map = GameState.world.map
var display_name = "d00r"

func _ready() -> void:
	add_to_group("entities")
	
func interact():
	is_open = !is_open
	print("Door toggled")
	update_tile_state()
	
func update_tile_state():
	if is_open:
		map[grid_y][grid_x] = 6
		
	else:
		map[grid_y][grid_x] = 3
		if animation_player.has_animation("Open_Out"):
			animation_player.play("Open_Out")
			await animation_player.animation_finished

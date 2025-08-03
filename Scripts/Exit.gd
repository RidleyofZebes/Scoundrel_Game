extends TileBase

@onready var animation_player := $blockbench_export/AnimationPlayer

var is_open = false
var is_locked = true
var grid_x: int = 0
var grid_y: int = 0
var map = GameState.world.map
var display_name = "Xit"

func _ready() -> void:
	add_to_group("entities")
	var anim = ""
	if is_open:
		anim = "Open"
	else:
		anim = "Close"
	if animation_player.has_animation(anim):
		animation_player.play(anim)
		if is_open:
			animation_player.seek(animation_player.current_animation_length, true)
		else:
			animation_player.seek(0, true)
			
func on_player_enter():
	MessageBox.say("Venture deeper into the unknown?")
	
func interact(interact_origin: Vector2i):
	var delta = interact_origin - Vector2i(grid_x, grid_y)
	var anim = ""
	if is_locked:
		MessageBox.say("The doors hold fast, appearing to be locked. Have you seen a key anywhere?")
	else:
		if is_open:
			anim = "Close"
		else:
			anim = "Open"

		is_open = !is_open
		update_tile_state(anim)
	
func update_tile_state(anim_name: String):
	if animation_player.has_animation(anim_name):
		animation_player.play(anim_name)
		print("Playing ", anim_name)
		await animation_player.animation_finished

extends Node

enum CursorMode { DEFAULT, LOOK, ATTACK, INTERACT, MOVE}
var current_mode: CursorMode = CursorMode.DEFAULT

func _ready():
	Input.set_custom_mouse_cursor(preload("res://Assets/cursor_gauntlet.png"))

func _unhandled_input(event):
	if event.is_action_pressed("cursor_mode_look"):
		set_cursor_mode(CursorMode.LOOK)
	elif event.is_action_pressed("cursor_mode_attack"):
		set_cursor_mode(CursorMode.ATTACK)
	elif event.is_action_pressed("cursor_mode_interact"):
		set_cursor_mode(CursorMode.INTERACT)
	elif event.is_action_pressed("cursor_mode_move"):
		set_cursor_mode(CursorMode.MOVE)
		
func set_cursor_mode(mode):
	current_mode = mode
	
	# Look Cursor setup
	var examine_cursor_image = preload("res://Assets/cursor_eye.png")
	var image_size = examine_cursor_image.get_size()
	var hotspot = image_size / 2
	
	match mode:
		CursorMode.LOOK:
			Input.set_custom_mouse_cursor(examine_cursor_image, Input.CURSOR_ARROW, hotspot)
		CursorMode.ATTACK:
			Input.set_custom_mouse_cursor(preload("res://Assets/cursor_gauntlet.png"))
		CursorMode.INTERACT:
			Input.set_custom_mouse_cursor(preload("res://Assets/cursor_gauntlet.png"))
		CursorMode.MOVE:
			Input.set_custom_mouse_cursor(preload("res://Assets/cursor_gauntlet.png"))
		_:
			Input.set_custom_mouse_cursor(null)

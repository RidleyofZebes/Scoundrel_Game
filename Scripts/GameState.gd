extends Node

enum CursorMode { DEFAULT, LOOK, ATTACK, INTERACT, MOVE}
var current_mode: CursorMode = CursorMode.DEFAULT

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
	match mode:
		CursorMode.LOOK:
			Input.set_custom_mouse_cursor(preload("res://icon.svg"))
		CursorMode.ATTACK:
			Input.set_custom_mouse_cursor(preload("res://icon.svg"))
		CursorMode.INTERACT:
			Input.set_custom_mouse_cursor(preload("res://icon.svg"))
		CursorMode.MOVE:
			Input.set_custom_mouse_cursor(preload("res://icon.svg"))
		_:
			Input.set_custom_mouse_cursor(null)

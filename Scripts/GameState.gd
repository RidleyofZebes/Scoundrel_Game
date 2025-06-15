extends Node

enum CursorMode { DEFAULT, LOOK, ATTACK, INTERACT, MOVE}
var current_mode: CursorMode = CursorMode.DEFAULT
var menu_screen: Control = null
var minimap: TextureRect = null          # HUD minimap
var menu_minimap: TextureRect = null     # Menu fullscreen minimap
var ui_root: CanvasLayer = null

func _ready():
	Input.set_custom_mouse_cursor(preload("res://Assets/Cursors/cursor_gauntlet.png"))

func _unhandled_input(event):
	if event.is_action_pressed("cursor_mode_look"):
		set_cursor_mode(CursorMode.LOOK)
	elif event.is_action_pressed("cursor_mode_attack"):
		set_cursor_mode(CursorMode.ATTACK)
	elif event.is_action_pressed("cursor_mode_interact"):
		set_cursor_mode(CursorMode.INTERACT)
	elif event.is_action_pressed("cursor_mode_move"):
		set_cursor_mode(CursorMode.MOVE)
	elif event.is_action_pressed("menu"):
		toggle_menu()
		
func toggle_menu():
	if not menu_screen or not minimap or not menu_minimap:
		push_warning("Missing UI references in GameState")
		return

	var is_open = not menu_screen.visible
	menu_screen.visible = is_open

	# Toggle visibility between minimaps
	minimap.visible = not is_open
	menu_minimap.visible = is_open
	
	# MessageBox.visible = not is_open

	if is_open:
		menu_minimap.set_player_pos(minimap.player_grid_pos, minimap.player_facing)
		menu_minimap.set_entities(minimap.entity_positions)
		menu_minimap.draw_minimap()
		
		
func set_cursor_mode(mode):
	current_mode = mode
	
	# Look Cursor setup
	var examine_cursor_image = preload("res://Assets/Cursors/cursor_eye.png")
	var image_size = examine_cursor_image.get_size()
	var hotspot = image_size / 2
	
	match mode:
		CursorMode.LOOK:
			Input.set_custom_mouse_cursor(examine_cursor_image, Input.CURSOR_ARROW, hotspot)
		CursorMode.ATTACK:
			Input.set_custom_mouse_cursor(preload("res://Assets/Cursors/cursor_gauntlet.png"))
		CursorMode.INTERACT:
			Input.set_custom_mouse_cursor(preload("res://Assets/Cursors/cursor_gauntlet.png"))
		CursorMode.MOVE:
			Input.set_custom_mouse_cursor(preload("res://Assets/Cursors/cursor_gauntlet.png"))
		_:
			Input.set_custom_mouse_cursor(null)

extends Node

const Player = preload("res://Scripts/Player.gd")

enum CursorMode { DEFAULT, LOOK, ATTACK, INTERACT, MOVE}
enum MenuType { NONE, MAP, INVENTORY, OPTIONS}
var current_mode: CursorMode = CursorMode.DEFAULT
var menu_type: MenuType = MenuType.NONE
var menu_screen: Control = null
var minimap: TextureRect = null          # HUD minimap
var menu_minimap: TextureRect = null     # Menu fullscreen minimap
var ui_root: CanvasLayer = null
var player: Player = null
var inventory_ui: Control = null
var menu_tabs: TabContainer = null
var open_container_node: Node = null
var world: Node = null

var konami_sequence := [
	KEY_UP, KEY_UP, KEY_DOWN, KEY_DOWN, KEY_LEFT, KEY_RIGHT, KEY_LEFT, KEY_RIGHT, KEY_B, KEY_A, KEY_TAB, KEY_ENTER
]
var konami_progress := 0
var cheats_enabled := true # TODO Change back to false when done with testing

func _ready():
	Input.set_custom_mouse_cursor(preload("res://Assets/Cursors/cursor_gauntlet.png"))
	inventory_ui = get_node("MenuScreen/TabContainer/InventoryTab/InventoryUi")

func _unhandled_input(event):
	if not cheats_enabled and event is InputEventKey and event.pressed:
		if event.keycode == konami_sequence[konami_progress]:
			konami_progress += 1
			if konami_progress == konami_sequence.size():
				cheats_enabled = true
				print("#### CHEATS ENABLED ####")
				MessageBox.say("You feel a shift in the fabric of reality...!")
				konami_progress = 0
		else:
			if event.keycode != konami_sequence[0] or konami_progress == 0:
				konami_progress = 0
	
	if event.is_action_pressed("cursor_mode_look"):
		set_cursor_mode(CursorMode.LOOK)
	elif event.is_action_pressed("cursor_mode_attack"):
		set_cursor_mode(CursorMode.ATTACK)
	elif event.is_action_pressed("cursor_mode_interact"):
		set_cursor_mode(CursorMode.INTERACT)
	elif event.is_action_pressed("cursor_mode_move"):
		set_cursor_mode(CursorMode.MOVE)
		
	elif event.is_action_pressed("inventory"):
		toggle_inventory()
	elif event.is_action_pressed("map"):
		toggle_map()
	elif event.is_action_pressed("ui_cancel"):
		if menu_type != MenuType.NONE:
			close_all_menus()
			return
	
	if cheats_enabled and event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_F1:
				_debug_reveal_map()
			KEY_F2:
				_debug_reveal_entities()
			KEY_F3:
				_debug_unlock_doors_chests()
				
func _debug_reveal_map():
	print("#### Map Revealed ####")
	MessageBox.say("The secrets of the realm are revealed to you...!")
	if minimap:
		minimap.reveal_all_tiles()
	if menu_minimap:
		menu_minimap.reveal_all_tiles()
		
func _debug_reveal_entities():
	print("#### Entities Revealed ####")
	MessageBox.say("Your senses expand to see beyond your limits...!")
	if minimap:
		world.reveal_all_entities()
	if menu_minimap:
		world.reveal_all_entities()

func _debug_unlock_doors_chests():
	print("#### Unlocking All Locks ####")
	MessageBox.say("You feel as if the world has been opened unto you...!")
	world.unlock_doors_chests()
		
func close_all_menus():
	if open_container_node:
		if open_container_node.has_method("close"):
			open_container_node.close()
		open_container_node = null
	menu_type = MenuType.NONE
	menu_screen.visible = false
	minimap.visible = true
	menu_minimap.visible = false
	if inventory_ui:
		inventory_ui.close()
		
func toggle_inventory():
	if menu_type == MenuType.INVENTORY:
		close_all_menus()
		return
	menu_type = MenuType.INVENTORY
	menu_screen.visible = true
	menu_tabs.current_tab = 1
	minimap.visible = false
	menu_minimap.visible = true
	inventory_ui.open(player.inventory)
	
func toggle_map():
	if menu_type == MenuType.MAP:
		close_all_menus()
		return
	menu_type = MenuType.MAP
	menu_screen.visible = true
	menu_tabs.current_tab = 0
	minimap.visible = false
	menu_minimap.visible = true
		
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
		
func open_container(container_node):
	open_container_node = container_node
	menu_type = MenuType.INVENTORY
	menu_screen.visible = true
	menu_tabs.current_tab = 1
	minimap.visible = false
	menu_minimap.visible = true
	if inventory_ui:
		inventory_ui.open(
			player.inventory, 
			container_node.inventory, 
			container_node.icon
			)
		print("Opening container:", container_node)
	else:
		push_warning("Inventory UI not assigned")
		
func close_inventory():
	if inventory_ui:
		inventory_ui.close()
		menu_screen.visible = false
		minimap.visible = true
		menu_minimap.visible = false
	
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
			

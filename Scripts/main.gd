extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameState.menu_screen = $MenuScreen
	GameState.minimap = $"UI/2dMinimap"
	GameState.menu_minimap = $MenuScreen/TabContainer/Map/MenuMinimap 
	GameState.ui_root = $UI
	GameState.inventory_ui = $MenuScreen/TabContainer/InventoryTab/InventoryUi
	GameState.menu_tabs = $MenuScreen/TabContainer

	GameState.minimap.pan_enabled = false
	GameState.menu_minimap.pan_enabled = true

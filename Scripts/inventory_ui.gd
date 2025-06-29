extends Control


@onready var player_grid = $VSplitContainer/PlayerSection/PlayerEquipment
@onready var player_avatar = $VSplitContainer/PlayerSection/PlayerPaperdoll
@onready var coin_label = $VSplitContainer/PlayerSection/CoinPurse
@onready var container_grid = $VSplitContainer/ContainerSection/ContainerInventory
@onready var container_avatar = $VSplitContainer/ContainerSection/ContainerAvatar

var player_inv: Inventory
var container_inv: Inventory
var slot_scene = preload("res://Scenes/UI Elements/InventorySlot.tscn")

func open(player_inventory: Inventory, container_inventory: Inventory = null, container_icon: Texture = null):
	player_inv = player_inventory
	container_inv = container_inventory
	refresh()
	
	container_grid.get_parent().visible = container_inv != null
	container_avatar.visible = container_inv != null
	
	if container_icon:
		container_avatar.texture = container_icon
		
	show()
	
func close():
	hide()
	
func refresh():
	var coins = player_inv.has("coinpurse") if player_inv.get("coinpurse") else 0
	coin_label.text = "Gold: %d" % coins
	
	_populate_grid(player_grid, player_inv)
	if container_inv:
		_populate_grid(container_grid, container_inv)
	else:
		for child in container_grid.get_children():
			child.queue_free()
		
func _populate_grid(grid: GridContainer, inv: Inventory):
	for child in grid.get_children():
		child.queue_free()
	for item in inv.get_items():
		var slot = slot_scene.instantiate()
		slot.set_item(item.id, item.count)
		grid.add_child(slot)

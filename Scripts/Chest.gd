extends Node


@export var container_type: String = "chest"
@onready var animation_player := $blockbench_export/AnimationPlayer

var inventory := Inventory.new()
var is_open := false
var examine_text := ""
var display_name := "Chest"
var grid_x: int = 0
var grid_y: int = 0

func _ready() -> void:
	add_to_group("entities")
	var container_data = ItemDB.get_container_data(container_type)
	var capacity = container_data.get("slots", 5)
	inventory.set_capacity(capacity)
	
	examine_text = container_data.get("examine", "You put things in it? Maybe?")
	display_name = container_data.get("name", "Container?")
	
	if animation_player.has_animation("Close"):
		animation_player.play("Close")
		animation_player.seek(0.0, true)
	
func interact():
	if is_open:
		close()
	else:
		open()
		
func is_blocking() -> bool:
	return false

func open():
	if not is_open:
		is_open = true
		if animation_player.has_animation("Open"):
			animation_player.play("Open")
		print("The chest contains:", inventory.get_items())
		
func close():
	if is_open:
		is_open = false
		if animation_player.has_animation("Close"):
			animation_player.play("Close")

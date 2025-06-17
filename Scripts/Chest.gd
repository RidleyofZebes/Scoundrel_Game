extends Node


@export var container_type: String = "chest"
@onready var animation_player := $blockbench_export/AnimationPlayer

var inventory := Inventory.new()
var is_open := false
var examine_text := ""
var display_name := "Chest"
var grid_x: int = 0
var grid_y: int = 0
var icon: Texture = preload("res://Assets/Interface/map_stencil.png") # TODO FIX PLACEHOLDER

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
	if not is_open:
		open()
		
func is_blocking() -> bool:
	return false

func open():
	if not is_open:
		is_open = true
		if animation_player.has_animation("Open"):
			animation_player.play("Open")
			await animation_player.animation_finished
			_on_chest_opened("Open")
		else:
			_on_chest_opened("Open")
		
		
func _on_chest_opened(anim_name: String) -> void:
	if anim_name == "Open":
		print("The chest contains:", inventory.get_items())
		print("Opening container:", self)
		GameState.open_container(self)
		
func close():
	if is_open:
		is_open = false
		if animation_player.has_animation("Close"):
			animation_player.play("Close")

extends Node3D


@export var vision_mode: int = 4 # Default is Torch

@onready var tween = $MoveTween

enum VisionMode { BLIND, DARKVISION, TORCH, LANTERN, BULLSEYE}


var grid_x: int
var grid_y: int
var health: int = 10
var map: Array = []
var facing: int  # 0=N, 1=E, 2=S, 3=W
var current_rotation_y: float = 0.0
var target_rotation_y: float = 0.0
var move_duration: float = 0.2  # seconds to move one tile
var move_elapsed: float = 0.0
var start_position: Vector3
var end_position: Vector3
var moving: bool = false



func _ready():
	current_rotation_y = rotation_degrees.y

func try_move(dx: int, dy: int) -> bool:
	if moving:
		return false
	
	var new_x = grid_x + dx
	var new_y = grid_y + dy
	if new_y < 0 or new_y >= map.size() or new_x < 0 or new_x >= map[0].size():
		print("can't move to ", new_x, " ", new_y, ", out of bounds!")
		return false
	if map[new_y][new_x] != 1:
		print("can't move!")
		return false
		
	grid_x = new_x
	grid_y = new_y
	moving = true
	start_position = position
	end_position = Vector3(grid_x, 0, grid_y)
	#move_elapsed = 0.0
	
	var tween = create_tween()
	tween.tween_property(self, "global_position", end_position, move_duration)
	tween.finished.connect(func(): moving = false, CONNECT_ONE_SHOT)
	

	print("Moving from ", start_position, " to ", end_position)
	
	var minimap = get_tree().get_root().get_node("Main/UI/2dMinimap")
	if minimap:
		minimap.set_player_pos(Vector2i(grid_x, grid_y), facing)
	else:
		print("Minimap not found, dumbass. You gave me: ", minimap)

	return true
	
func turn(direction):
	facing = (facing + direction) % 4
	if facing < 0:
		facing += 4
	target_rotation_y = float(facing * 90.0)
	
	var current_y = rotation_degrees.y
	var delta_angle = wrapf(target_rotation_y - current_rotation_y + 180.0, 0.0, 360.0) - 180.0
	var final_rotation = current_y + delta_angle
	
	var tween = create_tween()
	tween.tween_property(self, "rotation_degrees:y", final_rotation, 0.15)
	current_rotation_y = final_rotation
	
	var minimap = get_tree().get_root().get_node("Main/UI/2dMinimap")
	minimap.set_player_pos(Vector2i(grid_x, grid_y), facing)
	print("Now facing: ", facing)
	
#func set_rotation_y(val: float) -> void:
	#rotation_degrees.y = val
	
func take_damage(amount):
	health -= amount
	if health <= 0:
		die()

func die():
	queue_free()
	
func setup_light():
	match vision_mode:
		VisionMode.BLIND:
			return # You can't see shit
			
		VisionMode.DARKVISION:
			var light = OmniLight3D.new()
			light.omni_range = 8
			light.light_energy = 0.6
			light.light_color = Color(0.8, 0.8, 0.8)
			add_child(light)
			
		VisionMode.TORCH:
			var light = OmniLight3D.new()
			light.omni_range = 5
			light.light_energy = 2.0
			light.light_color = Color(1.0, 0.8, 0.6)
			add_child(light)
			
		VisionMode.LANTERN:
			var light = OmniLight3D.new()
			light.omni_range = 7
			light.light_energy = 2.5
			add_child(light)
			
		VisionMode.BULLSEYE:
			var light = SpotLight3D.new()
			light.spot_range = 10
			light.spot_angle = 45
			light.light_energy = 4.0
			light.light_color = Color(1.0, 1.0, 0.8)
			light.rotation_degrees.y = facing * 180.0
			add_child(light)

func _process(delta):
	pass

extends Node3D

@onready var camera: Camera3D = null
var camera_initial_position: Vector3
const LOOK_SHIFT_RADIUS := 0.15
var current_hovered : Node3D = null

func set_camera(cam: Camera3D) -> void:
	camera = cam
	camera_initial_position = cam.transform.origin

func _physics_process(delta: float) -> void:
	if GameState.current_mode != GameState.CursorMode.LOOK:
		if camera:
			camera.transform.origin = camera_initial_position
		clear_hover()
		return
		
	var mouse_pos = get_viewport().get_mouse_position()
	var viewport_size = get_viewport().size
	var center = viewport_size / 2.0
	var offset = (mouse_pos - center) / center
	offset.x *= LOOK_SHIFT_RADIUS
	offset.y *= -LOOK_SHIFT_RADIUS
	var target_pos = camera_initial_position + Vector3(offset.x, offset.y, 0) 
	camera.transform.origin = camera.transform.origin.lerp(target_pos, delta * 5.0)
	
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000
	
	var space_state = get_world_3d().direct_space_state
	var ray_params = PhysicsRayQueryParameters3D.create(from, to)
	ray_params.collision_mask = 1
	var result = space_state.intersect_ray(ray_params)
	
	if result and result.has("collider"):
		var collider = result.collider
		if collider != current_hovered:
			clear_hover()
			highlight_node(collider)
	else:
		clear_hover()
		
func _unhandled_input(event: InputEvent) -> void:
	if GameState.current_mode == GameState.CursorMode.LOOK and event.is_action_pressed("ui_accept"):
		if current_hovered and current_hovered.has_method("get_examine_text"):
			MessageBox.say(current_hovered.get_examine_text())
		
func clear_hover():
	if current_hovered and current_hovered.has_method("set_highlight"):
		current_hovered.set_highlight(false)
	current_hovered = null
	
func highlight_node(node):
	while node and not node.has_method("get_examine_text"):
		node = node.get_parent()
		
	if node:
		if node.has_method("set_highlight"):
			node.set_highlight(true)
			current_hovered = node
			# print("hovering on: ", node.name, node.tile_id)

class_name TileBase
extends Node3D

@export var examine_text := ""
@export var tile_id: int = -1
@onready var mesh: MeshInstance3D = null
@onready var glow_overlay := $GlowOverlay
var default_material = Material

func _ready() -> void:
	add_to_group("selectable")
	mesh = find_mesh_instance(self)
	if mesh:
		if mesh.material_override:
			mesh.material_override = mesh.material_override.duplicate()
			mesh.material_override.set_shader_parameter("highlight_enabled", false)
			default_material = mesh.material_override
		else: push_warning("Mesh has no material_override in tile: " + name)
	else:
		push_warning("MeshInstance3D not found in tile: " + name)
	
func find_mesh_instance(node: Node) -> MeshInstance3D:
	for child in node.get_children():
		if child is MeshInstance3D:
			return child
		if child.get_child_count() > 0:
			var result = find_mesh_instance(child)
			if result:
				return result
	return null

func set_highlight(enabled: bool) -> void:
	if glow_overlay:
		glow_overlay.visible = enabled
		
func get_examine_text() -> String:
	if tile_id >= 0:
		var tile_data = GlobalTileData.tile_defs.get(str(tile_id))
		if tile_data and tile_data.has("examine"):
			return tile_data["examine"]
	return "You are unsure what you are looking at...?"

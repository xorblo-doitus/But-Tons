@tool
class_name WireGizmoPlugin
extends EditorNode3DGizmoPlugin


func _init():
	create_material("main", Color(1, 0, 0))
	
	create_material("instant_connection", Color(0, 1, 0))
	create_material("progressive_connection", Color(0, 1, 1))
	create_material("resistance_connection", Color(1, 0.5, 0))
	
	create_handle_material("handles")


func _create_gizmo(for_node_3d: Node3D) -> EditorNode3DGizmo:
	if for_node_3d is LogicElement:
		return WireGizmo.new()
	return null


func _get_gizmo_name() -> String:
	return "WireGizmo"

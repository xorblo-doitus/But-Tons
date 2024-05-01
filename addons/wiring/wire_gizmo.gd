@tool
class_name WireGizmo
extends EditorNode3DGizmo


enum Tip {
	FROM,
	TO = -1,
}


var wire: Wire = get_node_3d()


func _init() -> void:
	_WiringPlugin.instance.scene_changed.connect(_on_editor_scene_changed)


func _add_tips_for_connection(new: LogicConnection) -> void:
	if not new:
		return
	
	var curve := wire.curve
	var connection := wire.connection
	
	if new.from and new.from.has_out_socket() and (curve.point_count == 0 or not curve.get_point_position(0).is_equal_approx(wire.to_local(new.from.get_global_out_socket_position()))):
		if connection == null or connection.from == null or not connection.from.has_out_socket():
			curve.add_point(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, 0)
			update_tips()
	
	if new.to and new.to.has_in_socket() and (curve.point_count == 0 or not curve.get_point_position(curve.point_count - 1).is_equal_approx(wire.to_local(new.from.get_global_in_socket_position()))):
		if connection == null or connection.to == null or not connection.to.has_in_socket():
			curve.add_point(Vector3.ZERO)
			update_tips()



func adapt_to_mode() -> void:
	if wire.connection == null:
		return
	
	match wire.connection.mode:
		LogicConnection.Mode.INSTANT:
			wire.material = Wire.ENABLED_MATERIAL
		LogicConnection.Mode.DELAYED:
			wire.material = Wire.DELAYED_MATERIAL.duplicate()
			print(wire.connection._gradient_texture)
			# TODO check that the editor save this relation
			wire.material.set_shader_parameter(&"on_gradient", wire.connection._gradient_texture)
		LogicConnection.Mode.RESISTANT:
			wire.material = Wire.RESISTANT_MATERIAL
			wire.radial_polygon_3d.set_instance_shader_parameter(&"progress", 1.0)


func update_tips() -> void:
	if wire.connection:
		update_tip(wire.connection.from, Tip.FROM)
		update_tip(wire.connection.to, Tip.TO)


func update_tip(element: LogicElement, tip: Tip) -> void:
	if element and (element.has_out_socket() if tip == Tip.FROM else element.has_in_socket()):
		var curve := wire.curve
		if curve.point_count == 0:
			curve.add_point(Vector3.ZERO)
		
		if tip == Tip.FROM:
			curve.set_point_position(0, wire.to_local(element.get_global_out_socket_position()))
			curve.set_point_out(0, element.out_socket_handle)
		else:
			curve.set_point_position(curve.point_count - 1, wire.to_local(element.get_global_in_socket_position()))
			curve.set_point_in(curve.point_count - 1, element.in_socket_handle)



var _editor_ready: bool = false
func _on_editor_scene_changed() -> void:
	_add_tips_for_connection(wire.connection)
	_editor_ready = true


func _on_connection_set() -> void:
	if _editor_ready:
		_add_tips_for_connection(wire.connection)
	adapt_to_mode()
	update_tips()

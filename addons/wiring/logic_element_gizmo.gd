@tool
class_name LogicElementGizmo
extends EditorNode3DGizmo


static var EDITOR_SELECTION = EditorInterface.get_selection()

static var CONNECTION_MATERIALS = {
	LogicConnection.Mode.INSTANT: "instant_connection",
	LogicConnection.Mode.DELAYED: "progressive_connection",
	LogicConnection.Mode.RESISTANT: "resistance_connection",
}


var _creator_handle_position: Vector3 = Vector3.ZERO
var _handle_nodes: Array[Node] = []


func _get_handle_name(handle_id: int, secondary: bool) -> String:
	if handle_id == 0:
		return "self"
	return "connect"

func _get_handle_value(handle_id: int, secondary: bool) -> Variant:
	if handle_id == 0:
		return _creator_handle_position
	return "Connected"


func _set_handle(handle_id: int, secondary: bool, camera: Camera3D, screen_pos: Vector2) -> void:
	if handle_id != 0:
		_select_from_handle(handle_id)
		return
	
	var node3d: Node3D = get_node_3d()
	
	_creator_handle_position = node3d.to_local(
		camera.project_position(
			screen_pos,
			camera.global_position.distance_to(node3d.global_position)
		)
	)
	node3d.update_gizmos()


func _commit_handle(handle_id: int, secondary: bool, restore: Variant, cancel: bool) -> void:
	if handle_id != 0:
		_select_from_handle(handle_id)
		return
	
	var node3d: Node3D = get_node_3d()
	
	var new_element: LogicElement = preload("res://src/world/interactive/logic_element.tscn").instantiate()
	new_element.position = _creator_handle_position
	node3d.add_sibling(new_element, true)
	new_element.owner = node3d.owner
	
	var new_connection: LogicConnection = preload("res://src/world/animated/logic/logic_connection.tscn").instantiate()
	new_connection.from = node3d
	new_connection.to = new_element
	new_element.add_child(new_connection, true)
	new_connection.owner = node3d.owner
	
	_creator_handle_position = Vector3.ZERO
	
	node3d.update_gizmos()


var _overlap_time: float = -1
func _redraw():
	#print("Update LogicElement gizmo.")
	
	clear()
	_handle_nodes.clear()
	
	var node3d: Node3D = get_node_3d()
	
	var handle_positions := PackedVector3Array([_creator_handle_position])

	for logic_connection: LogicConnection in node3d.get_tree().get_nodes_in_group(&"logic_connection"):
		if logic_connection.from != node3d and logic_connection.to != node3d:
			continue
		
		if not logic_connection.to or not logic_connection.from:
			continue
		
		if logic_connection.from == logic_connection.to:
			print("Unimplemented self connection line drawing")
			continue
		
		var start: Vector3 = node3d.to_local(logic_connection.from.global_position)
		var stop: Vector3 = node3d.to_local(logic_connection.to.global_position)
		
		if start == stop:
			# Not enough space to draw
			if _overlap_time < Time.get_ticks_msec():
				print("Can't draw connection of same positionned connections.")
				_overlap_time = Time.get_ticks_msec() + 500
			continue
		
		var material := get_plugin().get_material(CONNECTION_MATERIALS[logic_connection.mode], self)
		
		add_lines([start, stop], material, false)
		
		handle_positions.push_back((start + stop) / 2.0)
		_handle_nodes.push_back(logic_connection)
		
		#region Create arrow
		var arrow_position: Transform3D = Transform3D()
		
		var arrow_delta: float = min(0.25, start.distance_to(stop) / 2.0)
		
		if logic_connection.from == node3d:
			arrow_position.origin = start.move_toward(stop, arrow_delta)
		else:
			arrow_position.origin = stop.move_toward(start, arrow_delta)
		
		arrow_position = arrow_position.looking_at(stop)
		
		arrow_position.basis = Basis(
			arrow_position.basis.x,
			-arrow_position.basis.z,
			arrow_position.basis.y,
		)
		
		add_mesh(
			preload("res://addons/wiring/arrow.tres"),
			material,
			arrow_position,
		)
		#endregion
	
	for logic_element: LogicElement in node3d.get_tree().get_nodes_in_group(&"logic_element"):
		if logic_element != node3d:
			handle_positions.push_back(node3d.to_local(logic_element.global_position))
			_handle_nodes.push_back(logic_element)
	
	add_handles(handle_positions, get_plugin().get_material("handles", self), [])


func _select_from_handle(handle_id: int) -> void:
	PatousLib.select_node(_handle_nodes[handle_id - 1])

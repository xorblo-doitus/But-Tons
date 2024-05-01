@tool
#class_name Wire
extends Rope


const ENABLED_MATERIAL = preload("res://src/world/animated/logic/wires/materials/enabled.tres")
const DISABLED_MATERIAL = preload("res://src/world/animated/logic/wires/materials/disabled.tres")
const DELAYED_MATERIAL = preload("res://src/world/animated/logic/wires/materials/delayed.tres")
const RESISTANT_MATERIAL = preload("res://src/world/animated/logic/wires/materials/resistant.tres")


var _connection_connections: Array[AnonymousConnection] = [
	AnonymousConnection.new(&"mode_changed", _on_mode_changed),
	AnonymousConnection.new(&"changed", update),
]
@export var connection: LogicConnection:
	set(new):
		AnonymousConnection.change_target(connection, new, _connection_connections)
		
		if _editor_ready:
			_add_tips_for_connection(new)
		
		connection = new
		_on_connection_set()


func _init() -> void:
	if Engine.is_editor_hint():
		_connection_connections.pop_back()
		#_connection_connections[-1] = AnonymousConnection.new(&"targets_changed", update_sockets_importer)


func _ready() -> void:
	if not Engine.is_editor_hint():
		update()


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = PackedStringArray()
	if connection == null:
		warnings.push_back("This wire does not represent any LogicConnection.")
	return warnings


func _on_connection_set() -> void:
	_on_mode_changed()
	
	update_configuration_warnings()
	update_tips()
	#update_sockets_importer()


func _on_mode_changed() -> void:
	match connection.mode:
		LogicConnection.Mode.INSTANT:
			material = ENABLED_MATERIAL
		LogicConnection.Mode.DELAYED:
			if Engine.is_editor_hint():
				material = DELAYED_MATERIAL
			else:
				material = DELAYED_MATERIAL.duplicate()
				print(connection._gradient_texture)
				material.set_shader_parameter(&"on_gradient", connection._gradient_texture)
		LogicConnection.Mode.RESISTANT:
			material = RESISTANT_MATERIAL
			if Engine.is_editor_hint() and radial_polygon_3d:
				radial_polygon_3d.set_instance_shader_parameter.call_deferred(&"progress", 1.0)


var _editor_ready: bool = false
func _on_editor_scene_changed() -> void:
	_add_tips_for_connection(connection)
	update_tips()
	_editor_ready = true


func _add_tips_for_connection(new: LogicConnection) -> void:
	if not new:
		return
	
	if new.from and new.from.has_out_socket() and (curve.point_count == 0 or not curve.get_point_position(0).is_equal_approx(to_local(new.from.get_global_out_socket_position()))):
		if connection == null or connection.from == null or not connection.from.has_out_socket():
			curve.add_point(Vector3.ZERO, Vector3.ZERO, Vector3.ZERO, 0)
	
	if new.to and new.to.has_in_socket() and (curve.point_count == 0 or not curve.get_point_position(curve.point_count - 1).is_equal_approx(to_local(new.from.get_global_in_socket_position()))):
		if connection == null or connection.to == null or not connection.to.has_in_socket():
			curve.add_point(Vector3.ZERO)


func update() -> void:
	match connection.mode:
		LogicConnection.Mode.INSTANT:
			if connection.from.on:
				material = ENABLED_MATERIAL
			else:
				material = DISABLED_MATERIAL
		LogicConnection.Mode.RESISTANT:
			radial_polygon_3d.set_instance_shader_parameter(&"progress", connection.get_progress())


func update_tips() -> void:
	if connection.from:
		update_tip(connection.from, Tip.FROM)
	if connection.to:
		update_tip(connection.to, Tip.TO)
	#if connection.from and connection.from.has_out_socket():
		#if curve.point_count == 0:
			#curve.add_point(Vector3.ZERO)
		#curve.set_point_position(0, to_local(connection.from.get_global_out_socket_position()))
		#curve.set_point_out(0, connection.from.out_socket_handle)
	#
	#if connection.to and connection.to.has_out_socket():
		#if curve.point_count == 0:
			#curve.add_point(Vector3.ZERO)
		#curve.set_point_position(-1, to_local(connection.to.get_global_in_socket_position()))
		#curve.set_point_in(-1, connection.to.in_socket_handle)


enum Tip {
	FROM,
	TO = -1,
}
func update_tip(element: LogicElement, tip: Tip) -> void:
	if element and (element.has_out_socket() if tip == Tip.FROM else element.has_in_socket()):
		if curve.point_count == 0:
			curve.add_point(Vector3.ZERO)
		
		if tip == Tip.FROM:
			curve.set_point_position(0, to_local(element.get_global_out_socket_position()))
			curve.set_point_out(0, element.out_socket_handle)
		else:
			curve.set_point_position(curve.point_count - 1, to_local(element.get_global_in_socket_position()))
			curve.set_point_in(curve.point_count - 1, element.in_socket_handle)


#
### Editor only
#func update_sockets_importer() -> void:
	#if connection.from and connection.from.has_node("OutSocket"):
		#get_socket_importer("Out").from = connection.from.get_node("InSocket")
	#else:
		#remove_socket_importer("Out")
	#
	#if connection.to and connection.to.has_node("InSocket"):
		#get_socket_importer("In").from = connection.from.get_node("InSocket")
	#else:
		#remove_socket_importer("In")
#
#
### Editor only
#func remove_socket_importer(socket: String) -> void:
	#socket += "SocketImporter"
	#if has_node(socket):
		#get_node(socket).queue_free()
#
#
### Editor only
#func get_socket_importer(socket: String) -> Path3dImporter:
	#socket += "SocketImporter"
	#if has_node(socket):
		#return get_node(socket)
	#
	#var new_socket_importer: Path3dImporter = preload("res://src/world/inert/rope/path3D_import.tscn").instantiate()
	#new_socket_importer.to = self
	#new_socket_importer.name = socket
	#add_child(new_socket_importer)
	#new_socket_importer.owner = owner
	#
	#return new_socket_importer

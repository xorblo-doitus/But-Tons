@tool
class_name Wire
extends Rope


signal connection_changed


const ENABLED_MATERIAL = preload("res://src/world/animated/logic/wires/materials/enabled.tres")
const DISABLED_MATERIAL = preload("res://src/world/animated/logic/wires/materials/disabled.tres")
const DELAYED_MATERIAL = preload("res://src/world/animated/logic/wires/materials/delayed.tres")
const RESISTANT_MATERIAL = preload("res://src/world/animated/logic/wires/materials/resistant.tres")


var _connection_connections: Array[AnonymousConnection] = [
	#AnonymousConnection.new(&"mode_changed", _on_mode_changed),
	AnonymousConnection.new(&"changed", update),
]
@export var connection: LogicConnection:
	set(new):
		AnonymousConnection.change_target(connection, new, _connection_connections)
		
		connection = new
		update_configuration_warnings()
		connection_changed.emit()


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


func update() -> void:
	match connection.mode:
		LogicConnection.Mode.INSTANT:
			if connection.from.on:
				material = ENABLED_MATERIAL
			else:
				material = DISABLED_MATERIAL
		LogicConnection.Mode.RESISTANT:
			radial_polygon_3d.set_instance_shader_parameter(&"progress", connection.get_progress())



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

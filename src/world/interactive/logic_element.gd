@tool
class_name LogicElement
extends Node3D


signal activated
signal deactivated
signal state_changed(state: bool)

signal sockets_changed()
signal in_socket_changed()
signal out_socket_changed()


@export_group("Input and outputs")
@export var in_socket_position: Vector3 = Vector3.ZERO:
	set(new):
		in_socket_position = new
		in_socket_changed.emit()
		sockets_changed.emit()
@export var in_socket_handle: Vector3 = Vector3.ZERO:
	set(new):
		in_socket_handle = new
		in_socket_changed.emit()
		sockets_changed.emit()
@export var out_socket_position: Vector3 = Vector3.ZERO:
	set(new):
		out_socket_position = new
		out_socket_changed.emit()
		sockets_changed.emit()
@export var out_socket_handle: Vector3 = Vector3.ZERO:
	set(new):
		out_socket_handle = new
		out_socket_changed.emit()
		sockets_changed.emit()


var on: bool = false


func activate() -> void:
	if on:
		return
	
	on = true
	activated.emit()
	state_changed.emit(on)


func deactivate() -> void:
	if not on:
		return
	
	on = false
	deactivated.emit()
	state_changed.emit(on)


func set_state(state: bool) -> void:
	if state == on:
		return
	
	if state:
		activate()
	else:
		deactivate()


func has_in_socket() -> bool:
	return in_socket_position != Vector3.ZERO or in_socket_handle != Vector3.ZERO

func has_out_socket() -> bool:
	return out_socket_position != Vector3.ZERO or out_socket_handle != Vector3.ZERO


func get_global_in_socket_position() -> Vector3:
	return to_global(in_socket_position)
	
func get_global_out_socket_position() -> Vector3:
	return to_global(out_socket_position)

#
### Editor only
#func update_sockets() -> void:
	#if in_socket_position != Vector3.ZERO or in_socket_handle != Vector3.ZERO:
		#var socket := get_socket("In")
		#socket.curve.set_point_position(0, in_socket_position)
		#socket.curve.set_point_in(0, in_socket_handle)
	#else:
		#remove_socket("In")
	#
	#if out_socket_position != Vector3.ZERO or out_socket_handle != Vector3.ZERO:
		#var socket := get_socket("Out")
		#socket.curve.set_point_position(0, out_socket_position)
		#socket.curve.set_point_out(0, out_socket_handle)
	#else:
		#remove_socket("Out")
#
#
### Editor only
#func remove_socket(socket: String) -> void:
	#socket += "Socket"
	#if has_node(socket):
		#get_node(socket).queue_free()
#
#
### Editor only
#func get_socket(socket: String) -> Path3D:
	#socket += "Socket"
	#if has_node(socket):
		#return get_node(socket)
	#
	#var new_socket: Path3D = Path3D.new()
	#new_socket.name = socket
	#new_socket.curve = Curve3D.new()
	#new_socket.curve.add_point(Vector3.ZERO)
	#add_child(new_socket)
	#new_socket.owner = owner
	#
	#return new_socket

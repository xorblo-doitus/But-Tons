class_name AnonymousConnection
extends RefCounted



@export var signal_name: StringName
@export var callback: Callable
@warning_ignore("int_as_enum_without_cast", "int_as_enum_without_match")
@export var flags: ConnectFlags = 0


@warning_ignore("int_as_enum_without_cast", "int_as_enum_without_match")
func _init(_signal_name: StringName, _callback: Callable, _flags: ConnectFlags = 0) -> void:
	signal_name = _signal_name
	callback = _callback
	flags = _flags


static func change_target(from: Object, to: Object, connections: Array[AnonymousConnection]) -> void:
	if from:
		for connection in connections:
			if from.is_connected(connection.signal_name, connection.callback):
				from.disconnect(connection.signal_name, connection.callback)
	
	if to:
		for connection in connections:
			to.connect(connection.signal_name, connection.callback, connection.flags)

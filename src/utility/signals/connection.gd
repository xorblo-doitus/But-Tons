class_name Connection
extends RefCounted


## A utility class to help connecting methods to signals through code.


## The signal to wich the callback is connected
@export var connected_to: Signal
## The callable that is called by the signal emission.
@export var callback: Callable
@warning_ignore("int_as_enum_without_cast", "int_as_enum_without_match")
@export var flags: ConnectFlags = 0


@warning_ignore("int_as_enum_without_cast", "int_as_enum_without_match")
func _init(_connected_to: Signal, _callback: Callable, auto_connect: bool = false, _flags: ConnectFlags = 0) -> void:
	connected_to = _connected_to
	callback = _callback
	flags = _flags
	
	if auto_connect:
		create()


## Create the signal connection
func create() -> void:
	connected_to.connect(callback, flags)


## Remove the signal connection
func destroy() -> void:
	connected_to.disconnect(callback)


## Call [method destroy] on all elements of the array and clear the array.
static func destroy_all(connections: Array[Connection]) -> void:
	while connections:
		connections.pop_back().destroy()

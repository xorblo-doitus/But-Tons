#class_name LogicConnectionBackup
#extends Node
#
#
#signal changed
#
#
#var _from_connections: Array[AnonymousConnection] = [
	#AnonymousConnection.new(&"state_changed", _on_input_state_changed),
#]
#@export var from: LogicElement:
	#set(new):
		#AnonymousConnection.change_target(from, new, _from_connections)
		#from = new
#@export var to: LogicElement:
	#set(new):
		#to = new
#
#
#func _on_input_state_changed(new_state: bool) -> void:
	#changed.emit()
	#if to:
		#to.set_state(new_state)

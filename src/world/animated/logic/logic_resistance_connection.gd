#class_name LogicResistanceConnection
#extends LogicConnection
#
#
##@export_range(0, 2, 0.01, "or_greater", "suffix:sec") var duration_sec: float = 0.5
#
#
#var _progress: float = 0.0
#
#
#func _ready() -> void:
	#set_process(false)
#
#
#func _process(delta: float) -> void:
	#if from and from.on:
		#if _progress != duration_sec:
			#_progress += delta
			#if _progress >= duration_sec:
				#_progress = duration_sec
				#if to:
					#to.activate()
				#set_process(false)
	#else:
		#if _progress != 0.0:
			#if _progress == duration_sec and to:
				#to.deactivate()
			#_progress -= delta
			#if _progress <= 0.0:
				#_progress = 0.0
				#set_process(false)
	#changed.emit()
#
#
#func get_progress() -> float:
	#return _progress / duration_sec
#
#
#@warning_ignore("unused_parameter")
#func _on_input_state_changed(new_state: bool) -> void:
	#set_process(true)

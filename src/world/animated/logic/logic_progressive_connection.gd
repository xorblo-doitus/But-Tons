#class_name LogicProgressiveConnection
#extends LogicConnection
#
#
##@export_range(0, 2, 0.01, "or_greater", "suffix:sec") var duration_sec: float = 0.5
##
##
##var _on_stamps: Array[float] = []
##var _off_stamps: Array[float] = []
#
#
#var _gradient: GradientTexture1D = GradientTexture1D.new():
	#set(new): assert(false, "_gradient is Read Only")
#
#
#func _ready() -> void:
	#_gradient.gradient = Gradient.new()
	#_gradient.gradient.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_CONSTANT
#
#
#func _process(delta: float) -> void:
	## 2k is off, 2k+1 is on.
	#var first_new_state: int = 0
	#if _off_stamps and _on_stamps:
		#if _off_stamps[-1] < _on_stamps[-1]:
			#first_new_state = 1
	#else:
		#if _on_stamps:
			#first_new_state = 1
	#
	#var removed_on: int = _increase_stamps(_on_stamps, delta)
	#var removed_off: int = _increase_stamps(_off_stamps, delta)
	#_update_gradient()
	#
	#if to:
		#for new_state in range(first_new_state, removed_on + removed_off + first_new_state):
			#to.set_state(new_state%2)
#
#
#func get_gradient() -> GradientTexture1D:
	#return _gradient
#
#
#func _increase_stamps(array: Array[float], delta: float) -> int:
	#var initial_len: int = len(array)
	#
	#for i in initial_len:
		#array[i] += delta
		#if array[i] > duration_sec:
			#array.resize(i)
			#break
	#
	#return initial_len - len(array)
#
#
#func _update_gradient() -> void:
	#var gradient = _gradient.gradient
	#
	#for i in range(gradient.get_point_count()-1, 0, -1):
		#gradient.remove_point(i)
	#
	#gradient.set_offset(0, 0)
	#gradient.set_color(0, Color.WHITE if from.on  else Color.BLACK)
	#
	#for time in _on_stamps:
		#gradient.add_point(time / duration_sec, Color.BLACK)
	#for time in _off_stamps:
		#gradient.add_point(time / duration_sec, Color.WHITE)
	#
	##gradient.reverse()
#
#
#func _on_input_state_changed(new_state: bool) -> void:
	#var time_stamp: float = 0.0
	#
	#if _on_stamps and time_stamp >= _on_stamps[0]:
		#time_stamp = _on_stamps[0] - 1e-5
	#if _off_stamps and time_stamp >= _off_stamps[0]:
		#time_stamp = _off_stamps[0] - 1e-5
	#
	#if new_state:
		#_on_stamps.push_front(time_stamp)
	#else:
		#_off_stamps.push_front(time_stamp)

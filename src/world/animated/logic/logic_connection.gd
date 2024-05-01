@tool
class_name LogicConnection
extends Node


enum Mode {
	INSTANT,
	DELAYED,
	RESISTANT,
}


signal changed
signal mode_changed
signal targets_changed


var _from_connections: Array[AnonymousConnection] = [
	AnonymousConnection.new(&"state_changed", _on_input_state_changed),
]
@export var from: LogicElement:
	set(new):
		if not Engine.is_editor_hint():
			AnonymousConnection.change_target(from, new, _from_connections)
		if from:
			from.update_gizmos.call_deferred()
		from = new
		if from:
			from.update_gizmos()
		targets_changed.emit()
		update_configuration_warnings()
@export var to: LogicElement:
	set(new):
		if to:
			to.update_gizmos.call_deferred()
		to = new
		if to:
			to.update_gizmos()
		targets_changed.emit()
		update_configuration_warnings()
@export var mode: Mode = Mode.INSTANT: set = set_mode
@export_range(1e-10, 2, 0.01, "or_greater", "suffix:sec") var duration_sec: float = 0.5:
	set(new):
		new = duration_sec
		if duration_sec == 0:
			mode = Mode.INSTANT


# Delayed
const EMPTY_STAMPS: Array[float] = []
var _on_stamps: Array[float]
var _off_stamps: Array[float]
var _gradient_texture: GradientTexture1D

# Resitant
var _progress: float = 0.0



func _ready() -> void:
	set_process(false)


func _process(delta: float) -> void:
	match mode:
		Mode.INSTANT:
			set_process(false)
		Mode.DELAYED:
			_process_delayed(delta)
		Mode.RESISTANT:
			_process_resistant(delta)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = PackedStringArray()
	if from == null:
		warnings.push_back("from is null.")
	if to == null:
		warnings.push_back("to is null.")
	return warnings


func _process_delayed(delta: float) -> void:
	# 2k is off, 2k+1 is on.
	var first_new_state: int = 0
	if _off_stamps and _on_stamps:
		if _off_stamps[-1] < _on_stamps[-1]:
			first_new_state = 1
	else:
		if _on_stamps:
			first_new_state = 1
	
	var removed_on: int = _increase_stamps(_on_stamps, delta)
	var removed_off: int = _increase_stamps(_off_stamps, delta)
	_update_gradient()
	
	if to:
		for new_state in range(first_new_state, removed_on + removed_off + first_new_state):
			to.set_state(new_state%2)


func _process_resistant(delta: float) -> void:
	if from and from.on:
		if _progress != duration_sec:
			_progress += delta
			if _progress >= duration_sec:
				_progress = duration_sec
				if to:
					to.activate()
				set_process(false)
	else:
		if _progress != 0.0:
			if _progress == duration_sec and to:
				to.deactivate()
			_progress -= delta
			if _progress <= 0.0:
				_progress = 0.0
				set_process(false)
	changed.emit()



func _increase_stamps(array: Array[float], delta: float) -> int:
	var initial_len: int = len(array)
	
	for i in initial_len:
		array[i] += delta
		if array[i] > duration_sec:
			array.resize(i)
			break
	
	return initial_len - len(array)


func _update_gradient() -> void:
	var gradient = _gradient_texture.gradient
	
	for i in range(gradient.get_point_count()-1, 0, -1):
		gradient.remove_point(i)
	
	gradient.set_offset(0, 0)
	gradient.set_color(0, Color.WHITE if from.on  else Color.BLACK)
	
	for time in _on_stamps:
		gradient.add_point(time / duration_sec, Color.BLACK)
	for time in _off_stamps:
		gradient.add_point(time / duration_sec, Color.WHITE)


func _create_gradient_texture() -> GradientTexture1D:
	var new_gradient_texture: GradientTexture1D = GradientTexture1D.new()
	new_gradient_texture.gradient = Gradient.new()
	new_gradient_texture.gradient.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_CONSTANT
	return new_gradient_texture


func get_progress() -> float:
	if mode == Mode.INSTANT:
		return 1
	
	return _progress / duration_sec


func set_mode(new: Mode) -> void:
	if new == mode:
		return
	
	set_process(false)
	
	if not Engine.is_editor_hint():
		match mode:
			Mode.DELAYED:
				_gradient_texture = null
				_on_stamps = EMPTY_STAMPS
				_off_stamps = EMPTY_STAMPS
			Mode.RESISTANT:
				_progress = 0.0
		
		match new:
			Mode.DELAYED:
				_gradient_texture = _create_gradient_texture()
				_on_stamps = []
				_off_stamps = []
	
	mode = new
	
	if from:
		from.update_gizmos()
	if to:
		to.update_gizmos()
	
	mode_changed.emit()
	changed.emit()


func _on_input_state_changed(new_state: bool) -> void:
	match mode:
		Mode.INSTANT:
			changed.emit()
			if to:
				to.set_state(new_state)
		
		Mode.DELAYED:
			var time_stamp: float = 0.0
			
			if _on_stamps and time_stamp >= _on_stamps[0]:
				time_stamp = _on_stamps[0] - 1e-5
			if _off_stamps and time_stamp >= _off_stamps[0]:
				time_stamp = _off_stamps[0] - 1e-5
			
			if new_state:
				_on_stamps.push_front(time_stamp)
			else:
				_off_stamps.push_front(time_stamp)
			
			set_process(true)
		
		Mode.RESISTANT:
			set_process(true)

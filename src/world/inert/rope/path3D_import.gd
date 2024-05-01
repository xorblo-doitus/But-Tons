@tool
class_name Path3dImporter
extends Node



var _from_connections: Array[AnonymousConnection] = [
	AnonymousConnection.new(&"curve_changed", _update),
]
@export var from: Path3D:
	set(new):
		AnonymousConnection.change_target(
			from,
			new,
			_from_connections
		)
		from = new
@export var to: Path3D

@export_group("indices")
## Included
@export var start_i: int = 0
## Excluded
@export var end_i: int = 0
@export var specific_indices: Array[int]
@export var assignation_offset: int = 0
@export_group("")

@export var disabled: bool = false:
	set(new):
		disabled = new
		_update()


func _init() -> void:
	if not Engine.is_editor_hint():
		queue_free()


func _ready() -> void:
	set_process(Engine.is_editor_hint())
	if not Engine.is_editor_hint():
		return
	_update()


var _previous_pos: Vector3 = Vector3.ZERO
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	if from == null:
		return
	
	if _previous_pos != from.global_position:
		_previous_pos = from.global_position
		_update()


func _update() -> void:
	if disabled:
		return
	
	
	if from == null or to == null:
		return
	
	var indices: Array[int] = specific_indices.duplicate()
	indices.append_array(range(start_i, end_i))
	
	var from_curve: Curve3D = from.curve
	var to_curve: Curve3D = to.curve
	
	for i in indices:
		to_curve.set_point_position(
			i + assignation_offset,
			to.to_local(from.to_global(from_curve.get_point_position(i)))
		)
		
		to_curve.set_point_in(i + assignation_offset, from_curve.get_point_in(i))
		to_curve.set_point_out(i + assignation_offset, from_curve.get_point_out(i))
		to_curve.set_point_tilt(i + assignation_offset, from_curve.get_point_tilt(i))

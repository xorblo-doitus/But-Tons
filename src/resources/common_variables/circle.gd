@tool
class_name Circle
extends Resource


signal updated


@export_range(3, 64, 1, "or_greater") var points_count: int = 16:
	set(new):
		points_count = max(3, new)
		_update()
@export_range(0, 2, 0.01, "or_greater", "suffix:m") var radius: float = 0.5:
	set(new):
		radius = max(1e-5, new)
		_update()

var _cached_polygon: PackedVector2Array
var _is_cached_polygon_outdated: bool = true



## Returns a circular polygon described by this circle.
func get_polygon() -> PackedVector2Array:
	if _is_cached_polygon_outdated:
		_cached_polygon = _calculate_polygon()
	return _cached_polygon


func _update() -> void:
	_is_cached_polygon_outdated = true
	updated.emit()


func _calculate_polygon():
	var new_polygon = PackedVector2Array()
	
	for i in points_count:
		var progress_pi: float = 2.0 * PI * i / points_count
		
		new_polygon.append(Vector2(
			cos(progress_pi) * radius,
			sin(progress_pi) * radius
		))
	
	return new_polygon

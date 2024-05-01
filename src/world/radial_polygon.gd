@tool
extends CSGPolygon3D


var _circle_connections: Array[AnonymousConnection] = [
	AnonymousConnection.new(&"updated", update_points),
]
@export var circle: Circle:
	set(new):
		AnonymousConnection.change_target(circle, new, _circle_connections)
		circle = new


func update_points() -> void:
	if not Engine.is_editor_hint():
		return
	
	polygon = circle.get_polygon()

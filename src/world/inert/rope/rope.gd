@tool
class_name Rope
extends Path3D



@export var circle: Circle:
	set(new):
		circle = new
		_csg_setter(&"circle")
## The material of the rope.
## Can only be a [ShaderMaterial] or a descendant of [BaseMaterial3D].
@export var material: Material:
	set(new):
		material = new
		_csg_setter(&"material")


@onready var radial_polygon_3d: CSGPolygon3D = %Polygon3D


func _ready() -> void:
	for args in _csg_to_set_on_ready:
		_csg_setter(args[0], args[1])
	
	if circle == null:
		circle = radial_polygon_3d.circle


var _csg_to_set_on_ready: Array
func _csg_setter(property: StringName, self_property_name: StringName = property) -> void:
	if not has_node("Polygon3D"):
		_csg_to_set_on_ready.append([property, self_property_name])
		return
	
	%Polygon3D.set(property, self.get(self_property_name))


func _get_property_list() -> Array[Dictionary]:
	return []

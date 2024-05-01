@tool
extends Wire


func _on_connection_set() -> void:
	if Engine.is_editor_hint():
		return
	
	if connection:
		material.set_shader_parameter(&"on_gradient", connection.get_gradient())


func update() -> void:
	pass

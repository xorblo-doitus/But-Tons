@tool
extends HBoxContainer


@onready var select_wire_button: Button = $SelectWire


func _ready() -> void:
	if not is_inside_tree():
		# We are editing the scene, not using the plugin
		return
	
	EditorInterface.get_selection().selection_changed.connect(update_visibility)
	
	update_visibility()


var selected_connections: Array[LogicConnection] = []
func update_visibility() -> void:
	var selection: Array[Node] = EditorInterface.get_selection().get_selected_nodes()
	
	selected_connections.clear()
	if selection and is_only_type(LogicConnection, selection):
		selected_connections.append_array(selection)
		show()
	else:
		hide()
		return
	
	update_select_wire()


func update_select_wire() -> void:
	var wires := get_wires()
	match len(wires):
		0:
			select_wire_button.text = "No wire"
			select_wire_button.disabled = true
		1:
			select_wire_button.text = "Select wire"
			select_wire_button.disabled = false
		_:
			select_wire_button.text = "Select wires (" + str(len(wires)) + ")"
			select_wire_button.disabled = false


func reverse() -> void:
	for connection in selected_connections:
		var old_to: LogicElement = connection.to
		connection.to = connection.from
		connection.from = old_to


func select_wire() -> void:
	PatousLib.select_nodes(get_wires())


func get_wires() -> Array[Node]:
	var result: Array[Node] = []
	for wire: Wire in selected_connections[0].get_tree().get_nodes_in_group(&"wire"):
		if wire.connection in selected_connections:
			result.push_back(wire)
	return result


func create_wire() -> void:
	for connection in selected_connections:
		var new_wire: Wire = preload("res://src/world/animated/logic/wires/wire.tscn").instantiate()
		
		new_wire.curve = Curve3D.new()
		connection.add_sibling(new_wire)
		new_wire.owner = connection.owner
		
		new_wire.connection = connection
		
		PatousLib.select_node(new_wire)


func is_only_type(type: GDScript, nodes: Array = selected_connections) -> bool:
	for node in nodes:
		if not is_instance_of(node, type):
			return false
	return true

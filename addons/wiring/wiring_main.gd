@tool
class_name _WiringPlugin
extends EditorPlugin


const ConnectionTool = preload("res://addons/wiring/connection_tools.gd")

static var instance: _WiringPlugin

var logic_element_gizmo_plugin = LogicElementGizmoPlugin.new()
var connection_tool: ConnectionTool = preload("res://addons/wiring/connection_tools.tscn").instantiate()

func _enter_tree() -> void:
	instance = self
	add_node_3d_gizmo_plugin(logic_element_gizmo_plugin)
	add_control_to_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, connection_tool)
	EditorInterface.get_selection().selection_changed.connect(_on_selection_changed)
	scene_changed.connect(_on_scene_changed)


func _exit_tree() -> void:
	remove_node_3d_gizmo_plugin(logic_element_gizmo_plugin)
	remove_control_from_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, connection_tool)
	EditorInterface.get_selection().selection_changed.disconnect(_on_selection_changed)
	scene_changed.disconnect(_on_scene_changed)


var _transform_checks: Array[TransformCheck] = []

func _process(delta: float) -> void:
	for transform_check in _transform_checks:
		transform_check.check()


func _on_scene_changed(root: Node) -> void:
	if not root:
		return
	
	root.get_tree().call_group(&"_on_editor_scene_changed", &"_on_editor_scene_changed")
	


var _on_select_connections_to_disconnect: Array[Connection] = []
func _on_selection_changed() -> void:
	Connection.destroy_all(_on_select_connections_to_disconnect)
	_transform_checks.clear()
	for node in EditorInterface.get_selection().get_selected_nodes():
		if node is LogicElement:
			var callbacks: Array[Callable] = [node.update_gizmos]
			for wire: Wire in node.get_tree().get_nodes_in_group(&"wire"):
				if wire.connection:
					if wire.connection.from == node:
						var bound: Callable = wire.update_tip.bind(node, WireGizmo.Tip.FROM)
						callbacks.append(bound)
						_on_select_connections_to_disconnect.push_back(
							Connection.new(node.out_socket_changed, bound, true)
						)
					
					if wire.connection.to == node:
						var bound: Callable = wire.update_tip.bind(node, WireGizmo.Tip.TO)
						callbacks.append(bound)
						_on_select_connections_to_disconnect.push_back(
							Connection.new(node.in_socket_changed, bound, true)
						)
					
			_transform_checks.push_back(
				TransformCheck.new(node, callbacks)
			)


class TransformCheck extends RefCounted:
	var node: Node3D
	var callbacks: Array[Callable]
	var last_global_transform: Transform3D
	
	func _init(p_node: Node3D, p_callbacks: Array[Callable]) -> void:
		node = p_node
		callbacks = p_callbacks
		last_global_transform = node.global_transform
	
	func check() -> bool:
		if node.global_transform != last_global_transform:
			last_global_transform = node.global_transform
			for callback in callbacks:
				callback.call()
			return true
		return false

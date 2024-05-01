extends Node
class_name UNode


## Utilities for [Node]s


## Unparent the node, return [code]true[/code] if successful.
static func unparent(node: Node) -> bool:
	var parent: Node = node.get_parent()
	if parent == null:
		return false
	
	parent.remove_child(node)
	return true


## Removes child and queue free them.
static func clear_children(node: Node) -> void:
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()


## Removes child and queue free them if calling [param checker_callable] return
## true when called with the child.
static func clear_children_meeting(node: Node, checker_callable: Callable) -> void:
	for child in node.get_children():
		if checker_callable.call(child):
			node.remove_child(child)
			child.queue_free()

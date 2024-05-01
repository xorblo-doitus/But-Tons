class_name PatousLib
extends Object


## Helpers to create plugins



static func select_node(node: Node) -> void:
	EditorInterface.get_selection().clear()
	EditorInterface.get_selection().add_node(node)


static func select_nodes(nodes: Array[Node]) -> void:
	EditorInterface.get_selection().clear()
	for node in nodes:
		EditorInterface.get_selection().add_node(node)

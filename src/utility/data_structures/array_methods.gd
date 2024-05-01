class_name ArrayMethods
extends Object



static func get_with_default(array: Array, index: int, default = null):
	if is_index_valid(array, index):
		return array[index]
	return default



## Return true if the [code]index[/code] is not out of [code]array[/code]'s range.
static func is_index_valid(array: Array, index: int) -> bool:
	return index < array.size() and index >= array.size() * -1

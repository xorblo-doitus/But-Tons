extends Node
class_name USignal


## Utilities for [Signal]s


## Disconnect only if already connected.
func soft_disconnect(_signal: Signal, callable: Callable) -> bool:
	if _signal.is_connected(callable):
		_signal.disconnect(callable)
		return true
	
	return false

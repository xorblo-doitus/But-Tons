class_name Clickable
extends StaticBody3D


## Emitted when the players click on this.
signal clicked
signal released


var is_pressed: bool = false



func click() -> void:
	is_pressed = true
	clicked.emit()
	is_pressed = false
	released.emit()


func hold() -> void:
	is_pressed = true
	clicked.emit()


func release() -> void:
	is_pressed = false
	released.emit()

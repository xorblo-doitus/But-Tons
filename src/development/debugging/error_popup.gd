class_name ErrorPopup
extends AcceptDialog


## A singleton displaying errors to the user.
##
## Please use [method get_popup] on the singleton instead of modifying the singleton directly.


func _init() -> void:
	hide()


func _ready() -> void:
	if get_tree().root.always_on_top:
		always_on_top = true
		move_to_foreground()


## Set window's title with the given elements seperated by " - "
func set_title_elements(elements: Array[String] = []) -> void:
	# Add the software title so the user know that the error come from this software.
	elements.push_front(
		EasySettings.get_setting("application/config/name_localized").get(
			OS.get_locale_language(),
			EasySettings.get_setting("application/config/name")
		)
	)
	
	title = " - ".join(elements)


func get_popup() -> ErrorPopup:
	if not visible:
		return self
	
	var new: ErrorPopup =  preload("res://src/development/debugging/error_popup.tscn").instantiate()
	
	new.hide() # Just in case I forgot to hide it before saving the scene.
	new.visibility_changed.connect(new.auto_free)
	get_tree().root.add_child.call_deferred(new)
	
	return new


func auto_free() -> void:
	if not visible:
		queue_free()

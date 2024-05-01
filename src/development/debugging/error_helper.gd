class_name ErrorHelper
extends RefCounted


## A utility class to handle errors
##
## Gives usefull error handling and formating methods.
## An instance of this class is supposed to represent an occurence of an error.


enum Level {
	INFO,
	WARNING,
	ERROR,
}

## [b]Note:[/b] Please enter the translated text, not the translation key.
var title: String = ""
## [b]Note:[/b] Please enter the translated text, not the translation key.
var description: String = ""
var godot_builtin_error: Error = FAILED
var level: Level = Level.ERROR


func _init(_title: String = "", _description: String = "", _godot_builtin_error: Error = FAILED) -> void:
	title = _title
	description = _description
	godot_builtin_error = _godot_builtin_error


## Chainable
func set_title(new: String) -> ErrorHelper:
	title = new
	return self


## Chainable
func set_description(new: String) -> ErrorHelper:
	description = new
	return self


## Chainable
func set_godot_builtin_error(new: Error) -> ErrorHelper:
	godot_builtin_error = new
	return self


## Chainable
func set_level(new: Level) -> ErrorHelper:
	level = new
	return self


func _to_string() -> String:
	var result: String = tr(&"ERROR_PREFIX") + title
	if godot_builtin_error:
		result += " - " + tr("ERROR_STRING").format({
			"godot_builtin_error": godot_builtin_error,
			"error_as_text": error_string(godot_builtin_error)
		})
	
	if description:
		result += "\n" + description
	
	return result


func get_title_elements() -> Array[String]:
	var title_elements: Array[String] = []
	if title:
		title_elements.append(title)
	if godot_builtin_error != OK:
		title_elements.append(tr("ERROR_STRING").format({
			"godot_builtin_error": godot_builtin_error,
			"error_as_text": error_string(godot_builtin_error)
		}))
	return title_elements


func get_shown_description() -> String:
	if description:
		return description
	
	return TranslationServer.tr(&"ERROR_WITHOUT_DESCRIPTION")


## Only popup if godot_builtin_error != 0.
## Returns godot_builtin_error.
func popup_if_godot_builtin_error(print_too: bool = true) -> int:
	if godot_builtin_error:
		popup(print_too)
	return godot_builtin_error


## Craetes a popup displaying this error.
func popup(print_too: bool = true) -> void:
	var title_elements: Array[String] = get_title_elements()
	var description_to_show: String = get_shown_description()
	
	if print_too:
		print_to_console(title_elements, description_to_show)
	
	var error_popup: ErrorPopup = ErrorPopupSingleton.get_popup()
	error_popup.set_title_elements(title_elements)
	error_popup.dialog_text = description_to_show
	error_popup.show()


static func _UNPASSED_CALLABLE(): pass
func print_to_console(
	title_elements: Array[String] = get_title_elements(),
	description_to_show: String = get_shown_description(),
	print_callable:Callable = _UNPASSED_CALLABLE
) -> void:
	var title_to_show: String = " - ".join(title_elements)
	var msg: String = title_to_show + "\n" + description_to_show
	if print_callable != _UNPASSED_CALLABLE:
		print_callable.call(msg)
	else:
		match level:
			Level.ERROR:
				push_error(title_to_show)
			Level.WARNING:
				push_warning(title_to_show)
			Level.INFO:
				print(title_to_show)
		printerr(title_to_show)
		print(description_to_show)
		print_stack()

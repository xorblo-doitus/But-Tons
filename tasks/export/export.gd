extends Control

## A scene to make exporting projects easier.

const QUICK_EXPORT_NAME = "quick_export"
const EXTENSIONS = {
	"html": ".html",
	"windows": ".exe",
	"linux": ".x86_64",
}

@onready var output: CodeEdit = $HBoxContainer/Output
@onready var debug_check_box: CheckBox = $HBoxContainer/Controls/Debug
@onready var export_name_edit: LineEdit = $HBoxContainer/Controls/ExportName
@onready var only_pck_check_box: CheckBox = $HBoxContainer/Controls/OnlyPCK
@onready var plateforms_list: ItemList = $HBoxContainer/Controls/Plateforms
@onready var already_exist: ConfirmationDialog = $AlreadyExist

var arguments := OS.get_cmdline_user_args()
var debug: bool:
	get:
		return debug_check_box.button_pressed
	set(new):
		debug_check_box.button_pressed = new
var only_pck: bool:
	get:
		return only_pck_check_box.button_pressed
	set(new):
		only_pck_check_box.button_pressed = new
var plateforms: Array[StringName]:
	get:
		var temp := plateforms_list.get_selected_items()
		var result: Array[StringName] = []
		for item_idx in temp:
			result.append(plateforms_list.get_item_text(item_idx))
		return result
	set(new):
		if &"all" in new:
			for item_idx in plateforms_list.item_count:
				plateforms_list.select(item_idx, false)
		else:
			plateforms_list.deselect_all()
			for item_idx in plateforms_list.item_count:
				if plateforms_list.get_item_text(item_idx) in new:
					plateforms_list.select(item_idx, false)

func _ready() -> void:
	get_window().always_on_top = false
	get_window().size = DisplayServer.screen_get_size() * 0.7
	get_window().move_to_center()
	
	_print("Export arguments are: ", arguments)
	
	debug = "--debug" in arguments
	
	for argument in arguments:
		if argument.begins_with("--to:"):
			plateforms = argument.trim_prefix("--to:").split(",")
			continue
	
	if not plateforms:
		plateforms = [&"all"]
	
	if "--quick" in arguments:
		quick_export()


func export(export_name: String = "") -> void:
	if export_name == "":
		export_name = export_name_edit.text
	
	if export_name == "":
		_print("Error, can't export with unnamed filename.")
		return
	
	var is_quick_export: bool = export_name == QUICK_EXPORT_NAME
	
	_print("Exporting", " only the PCK" if only_pck else "", ' as "%s"' % export_name, " with debug" if debug else "")
	_print_indentation += 1
	
	var common_export_arguments: Array[String] = []
	common_export_arguments.append("--headless")
	if debug:
		common_export_arguments.append("--export-debug")
	elif only_pck:
		common_export_arguments.append("--export-pack")
	else:
		common_export_arguments.append("--export-release")
	
	for plateform in plateforms:
		_print("Exporting for ", plateform, ":")
		_print_indentation += 1
		
		var directory: String = (
			"res://docs/play".path_join(export_name)
			if plateform == &"html_github_pages" else
			"res://exports".path_join(plateform).path_join(export_name)
		)
		if DirAccess.dir_exists_absolute(directory) and not is_quick_export:
			already_exist.show()
			if not await already_exist.choosed:
				continue
		else:
			DirAccess.make_dir_recursive_absolute(directory)
		
		var file_path: String = directory.path_join("index" if plateform == &"html" else export_name)
		if is_quick_export:
			file_path += EXTENSIONS.get(plateform, "")
		else:
			file_path += ".zip"
		
		var manual_zipping: bool = plateform == &"html" and file_path.ends_with(".zip")
		if manual_zipping:
			_print("Manually zipping enabled.")
			file_path = file_path.trim_suffix(".zip")
		
		var export_arguments: Array = common_export_arguments + [plateform, file_path]
		_print("Arguments passed to Godot are: ", " ".join(export_arguments))
		var pid := OS.create_instance(export_arguments)
		while OS.is_process_running(pid):
			await Wait.secondes(0.5)
		_print("Subprocess exited.")
		
		if manual_zipping:
			_print("Zipping generated files.")
			if FileAccess.file_exists(file_path + ".zip"):
				var err := DirAccess.remove_absolute(file_path + ".zip")
				if err:
					ErrorHelper.new("Failed to remove preexisting zip.").set_godot_builtin_error(err).popup()
			
			var names_of_file_to_zip := DirAccess.get_files_at(directory) # Get it before creating the ZIP.
			_print("Files to zip: ", names_of_file_to_zip)
			
			var zip: ZIPPacker = ZIPPacker.new()
			var error := zip.open(file_path + ".zip")
			if error:
				ErrorHelper.new("Error creating ZIPPacker").set_godot_builtin_error(error).popup()
			else:
				for filename in names_of_file_to_zip:
					var file_start_error := zip.start_file(filename)
					if file_start_error:
						ErrorHelper.new("Error starting file in ZIP").set_godot_builtin_error(file_start_error).popup()
						break
					var file_write_error := zip.write_file(FileAccess.get_file_as_bytes(directory.path_join(filename)))
					if file_write_error:
						ErrorHelper.new("Error writing file in ZIP").set_godot_builtin_error(file_write_error).popup()
						break
					var file_close_error := zip.close_file()
					if file_close_error:
						ErrorHelper.new("Error closing file in ZIP").set_godot_builtin_error(file_write_error).popup()
						break
				_print("Zipped successfully.")
		
		_print_indentation -= 1
	
	_print_indentation -= 1


func quick_export() -> void:
	export(QUICK_EXPORT_NAME)


func _on_quick_export_pressed() -> void:
	quick_export()


var _print_indentation: int = 0
func _print(
	msg1 = "",
	msg2 = "",
	msg3 = "",
	msg4 = "",
	msg5 = "",
) -> void:
	var msg: String = (
		"\t".repeat(_print_indentation)
		+ str(msg1)
		+ str(msg2)
		+ str(msg3)
		+ str(msg4)
		+ str(msg5)
	)
	
	print(msg)
	output.text += "\n" + msg


func _on_export_pressed() -> void:
	export()

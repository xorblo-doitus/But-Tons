extends Node

## Input singleton running constantly


func _process(_delta) -> void:
	if Input.is_action_just_pressed("menu"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	
	if Input.is_action_just_pressed("fullscreen"):
		# Get opposite state as current
		var now_fullscreen = get_window().mode != Window.MODE_FULLSCREEN
		
		print("set fullscreen to ", now_fullscreen)
		if now_fullscreen:
			get_window().mode = Window.MODE_FULLSCREEN
		else:
			get_window().mode = Window.MODE_WINDOWED
	
	
	if Input.is_action_just_pressed("screenshot"):
		var screenshot: Image = get_viewport().get_texture().get_image()
		
		var dir_path: String = EasySettings.get_setting("custom/file_system/pathes/screenshot")
		DirAccess.make_dir_recursive_absolute(dir_path)
		
		var _time_dict: Dictionary = Time.get_datetime_dict_from_system()
		
		var screenshot_id: String = ST.datetime_dict_to_string(_time_dict)
		var file_name = "screenshot_" + screenshot_id
		
		if FileAccess.file_exists(dir_path.path_join(file_name + ".png")):
			var counter: int = 2
			while FileAccess.file_exists(file_name + ("_%02d" % counter)):
				counter += 1
			file_name = file_name + ("_%02d" % counter)
		
		var file_path: String = dir_path.path_join(file_name) + ".png"
		
		# TODO Error handling
		screenshot.save_png(file_path)
		
		print("screenshot saved under ", ProjectSettings.globalize_path(file_path))

class_name Player
extends CharacterBody3D


const SPLIT_VIEW_UNLOCKING_DURATION = 1.0
const SPLIT_VIEW_ROTATION = PI / 48


@export var speed: = 5.0
@export var jump_velocity: = 4.5
@export_range(0, 100, 0.01, "or_greater", "suffix:m") var click_distance: float = 10:
	set(new):
		click_distance = new
		if main_button_caster:
			main_button_caster.distance = click_distance
		for button_caster in get_all_button_casters():
			button_caster.distance = click_distance

@export_group("sensitivity")
@export var sensitivity: = -0.005
@export var sensitivity_x: = 1
@export var sensitivity_y: = 1

@export_group("camera_limit")
@export var camera_limit_up: = deg_to_rad(90)
@export var camera_limit_down: = deg_to_rad(-90)

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var split_view_x_enabled: bool = false
var split_view_y_enabled: bool = false
var split_view_unlocked: bool = false
var split_view_unlocking: float = 0.0

## Stores [ButtonCaster]s. button_casters[0][0] is the center one.
var button_casters: Array[Array] = [
	[null, null, null],
	[null, null, null],
	[null, null, null],
]
## Set the element at [member button_casters][x][y]
func set_button_caster(x: int, y: int, button_caster: ButtonCaster) -> void:
	button_casters[x][y] = button_caster
## Get the element at [member button_casters][x][y]
func get_button_caster(x: int, y: int) -> ButtonCaster:
	return button_casters[x][y]
func get_all_button_casters() -> Array[ButtonCaster]:
	var result: Array[ButtonCaster] = []
	for column in button_casters:
		for button_caster in column:
			if button_caster:
				result.append(button_caster)
	return result

@onready var main_button_caster: ButtonCaster = %MainButtonCaster
@onready var view: Node3D = %View
@onready var camera: Camera3D = %Camera3D
@onready var split_screen_shader: ColorRect = %SplitScreenShader


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	set_button_caster(0, 0, main_button_caster)
	main_button_caster.distance = click_distance


func _process(delta: float) -> void:
	if not split_view_unlocked:
		if (
			is_input_splitting_horizontally()
			or is_input_splitting_vertically()
		) and not split_view_unlocked:
			split_view_unlocking += delta
			if split_view_unlocking >= SPLIT_VIEW_UNLOCKING_DURATION:
				split_view_unlocked = true
		else:
			split_view_unlocking = max(0, split_view_unlocking - delta * 2)
		


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed(&"jump") and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector(&"left", &"right", &"forward", &"backward")
	var direction := (basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	if split_view_unlocked:
		if split_view_x_enabled:
			if not is_input_splitting_horizontally():
				split_view_x_enabled = false
				print("Remove horizontal split")
				remove_button_caster(-1)
				remove_button_caster(1)
				split_screen_shader.material.set_shader_parameter(
					"horizontal_split_pixel",
					0
					#(view.get_node("RightButtonCaster").screen_position.x - get_viewport().size.x)/get_viewport().size.x
				)
				if split_view_y_enabled:
					remove_corner_button_casters()
		else:
			if is_input_splitting_horizontally():
				split_view_x_enabled = true
				print("Create horizontal split")
				create_button_caster(-1)
				create_button_caster(1)
				split_screen_shader.material.set_shader_parameter(
					"horizontal_split_pixel",
					16
					#(view.get_node("RightButtonCaster").screen_position.x - get_viewport().size.x)/get_viewport().size.x
				)
				if split_view_y_enabled:
					create_corner_button_casters()
		
		if split_view_y_enabled:
			if not is_input_splitting_vertically():
				split_view_y_enabled = false
				print("Remove vertical split")
				remove_button_caster(0, -1)
				remove_button_caster(0, 1)
				split_screen_shader.material.set_shader_parameter(
					"vertical_split_pixel",
					0
				)
				if split_view_x_enabled:
					remove_corner_button_casters()
		else:
			if is_input_splitting_vertically():
				split_view_y_enabled = true
				print("Create vertical split")
				create_button_caster(0, -1)
				create_button_caster(0, 1)
				split_screen_shader.material.set_shader_parameter(
					"vertical_split_pixel",
					16
				)
				if split_view_x_enabled:
					create_corner_button_casters()
		

	move_and_slide()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouse:
		if event is InputEventMouseMotion:
			#camera_3d.rotate_x(event.relative.y * sensitivity * sensitivity_y)
			view.rotation.x = clamp(
				view.rotation.x + event.relative.y * sensitivity * sensitivity_y,
				camera_limit_down,
				camera_limit_up,
			)
			rotate_y(event.relative.x * sensitivity * sensitivity_y)
		if event is InputEventMouseButton:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func is_input_splitting_horizontally() -> bool:
	return Input.is_action_pressed(&"left") and Input.is_action_pressed(&"right")
	
func is_input_splitting_vertically() -> bool:
	return Input.is_action_pressed(&"forward") and Input.is_action_pressed(&"backward")


func create_corner_button_casters() -> void:
	for x in [-1, 1]:
		for y in [-1, 1]:
			create_button_caster(x, y)
func remove_corner_button_casters() -> void:
	for x in [-1, 1]:
		for y in [-1, 1]:
			remove_button_caster(x, y)


const CASTER_NAMES_X = ["", "Right", "Left"]
const CASTER_NAMES_Y = ["", "Down", "Up"]
func create_button_caster(x: int = 0, y: int = 0) -> ButtonCaster:
	var instance: ButtonCaster = preload("res://src/world/entities/player/button_caster.tscn").instantiate()
	
	instance.camera = camera
	instance.on_screen_rotation = Vector2(x * SPLIT_VIEW_ROTATION, y * SPLIT_VIEW_ROTATION)
	instance.distance = click_distance
	instance.name = CASTER_NAMES_X[x] + CASTER_NAMES_Y[y] + "ButtonCaster"
	
	set_button_caster(x, y , instance)
	view.add_child(instance)
	
	return instance


func remove_button_caster(x: int = 0, y: int = 0) -> void:
	var button_caster: ButtonCaster = get_button_caster(x, y)
	set_button_caster(x, y, null)
	button_caster.queue_free()

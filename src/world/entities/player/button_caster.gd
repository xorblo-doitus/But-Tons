class_name ButtonCaster
extends RayCast3D

@export_range(0, 100, 0.01, "or_greater", "suffix:m") var distance: float = 10:
	set(new):
		distance = new
		target_position.z = -distance
@export var on_screen_rotation: Vector2 = Vector2(0, 0):
	set(new):
		on_screen_rotation = new
		
		rotation.x = -new.y
		rotation.y = -new.x
		update_reticle_position()
	#get:
		#return  Vector2(-rotation.y, rotation.x)
@export var camera: Camera3D:
	set(new):
		camera = new
		update_reticle_position()


var screen_position: Vector2 = Vector2.ZERO


@onready var reticle: ColorRect = %Reticle


func _ready() -> void:
	update_reticle_position()


@warning_ignore("unused_parameter")
func _set(property: StringName, value: Variant) -> bool:
	match property:
		&"rotation":
			update_reticle_position()
	return false


#var _currently_clicking: bool = false
#var _currently_clicking_on: Clickable
#func _unhandled_input(event: InputEvent) -> void:
	#if event.is_action(&"click"):
		## WARNING don't use double click, as it can be bound to non-mouse inputs.
		#if event.is_pressed():
			#if is_colliding():
				#_currently_clicking = true
				#_currently_clicking_on = get_target()
				#_currently_clicking_on.click()
		#else:
			#if is_colliding():
				#_currently_clicking = false
				#if _currently_clicking_on:
					#get_target().release()
					#_currently_clicking_on = null


func get_target() -> Clickable:
	return get_collider()


var _was_clicking_on: Clickable:
	set(new):
		if not Input.is_action_pressed(&"click"):
			if _was_clicking_on:
				_was_clicking_on.release()
				_was_clicking_on = null
			return
		
		if _was_clicking_on == new:
			return
		
		if _was_clicking_on:
			_was_clicking_on.release()
		
		if new:
			new.hold()
		
		_was_clicking_on = new

@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	var current_target: Object = get_collider()
	if is_colliding() and current_target is Clickable:
		reticle.rotation = PI / 4
		_was_clicking_on = current_target
	else:
		reticle.rotation = 0
		_was_clicking_on = null


func update_reticle_position() -> void:
	if camera == null or reticle == null:
		return
	
	screen_position = camera.unproject_position(to_global(target_position + Vector3(0, 0, -1)))
	reticle.position = screen_position - reticle.size / 2.0
	#reticle.position = camera.unproject_position(to_global(target_position)) - reticle.size / 2.0


#func get_reticle_pos() -> Vector2:
	#return reticle.position

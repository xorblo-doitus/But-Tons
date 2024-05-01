@tool
class_name BaseButton3D
extends LogicElement


const MATERIALS = [
	preload("res://src/world/interactive/buttons/materials/red_button.tres"),
	preload("res://src/world/interactive/buttons/materials/white_button.tres"),
	preload("res://src/world/interactive/buttons/materials/purple_button.tres"),
]


enum Mode {
	## Enabled as long as the button is pressede
	HOLD,
	## (aka Flip flop)
	TOGGLE,
	## Acts like if the button was held [member time_s] longer.
	EXTEND,
}


@export var mode: Mode = Mode.HOLD:
	set(new):
		mode = new
		if Engine.is_editor_hint() and is_node_ready():
			$Pushable/MeshInstance3D.material_override = MATERIALS[mode]
@export var time_s: float = 1.0

@onready var timer: Timer = $Timer
@onready var pushable_material: StandardMaterial3D


func _ready() -> void:
	set_process(false)
	if Engine.is_editor_hint():
		$Pushable/MeshInstance3D.material_override = MATERIALS[mode]
		return
	
	pushable_material = MATERIALS[mode].duplicate()
	$Pushable/MeshInstance3D.material_override = pushable_material


@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	match mode:
		Mode.EXTEND:
			pushable_material.emission_energy_multiplier = timer.time_left ** 1.5
		_:
			set_process(false)


func _on_clicked() -> void:
	match mode:
		Mode.HOLD:
			activate()
		Mode.TOGGLE:
			set_state(not on)
		Mode.EXTEND:
			set_process(false)
			timer.stop()
			activate()


func _on_released() -> void:
	match mode:
		Mode.HOLD:
			deactivate()
		Mode.EXTEND:
			timer.start(time_s)
			set_process(true)


func _on_timer_timeout() -> void:
	match mode:
		Mode.EXTEND:
			set_process(false)
			pushable_material.emission_energy_multiplier = 0
			deactivate()
		_:
			assert(false, "Timer should not end while in mode " + Mode.keys()[mode])


func _on_activated() -> void:
	pushable_material.emission_energy_multiplier = 1


func _on_deactivated() -> void:
	pushable_material.emission_energy_multiplier = 0

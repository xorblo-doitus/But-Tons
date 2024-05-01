extends Node

## Utility for waiting easily

@onready var tree := get_tree()

func minutes(time: float) -> void:
	await secondes(time*60)

func secondes(time: float) -> void:
	await tree.create_timer(time).timeout

func ms(time: float) -> void:
	await secondes(time/1000)


func process_frames(frames: int = 1) -> void:
	for __ in frames:
		await tree.process_frame

func physics_frames(frames: int = 1) -> void:
	for __ in frames:
		await tree.physics_frame

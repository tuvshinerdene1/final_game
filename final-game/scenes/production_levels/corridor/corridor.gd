extends Node3D

@onready var elevator = $Elevator
@export var is_elevator_disabled : bool = false

func _ready() -> void:
	# This will trigger the 'set(value)' in the Elevator script immediately
	if is_elevator_disabled:
		elevator.perma_closed = true

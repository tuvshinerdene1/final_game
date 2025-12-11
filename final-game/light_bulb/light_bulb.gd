@tool
extends Node3D
@export var light_color:Color = Color.WHITE:
	set(value):
		light_color = value
		_update_light()
@export_range(0.0, 100.0, 0.1) var light_energy: float = 1.0:
	set(value):
		light_energy = value
		_update_light()

@onready var omnilight: OmniLight3D = $OmniLight3D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_light()


func _update_light():
	if omnilight:
		omnilight.light_color = light_color
		omnilight.light_energy = light_energy

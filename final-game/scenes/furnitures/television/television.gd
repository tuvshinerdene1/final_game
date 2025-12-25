extends Node3D


@export var video_path_parent: String = "" 
@onready var screen = $screen
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen.video_path = video_path_parent
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

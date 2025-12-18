extends Node3D
@onready var anim :AnimationPlayer = $AnimationPlayer
@export_enum("Male", "Female") var gender: String = "Male"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if gender == "Male":
		anim.play("male_default")
	else:
		anim.play("female_default")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

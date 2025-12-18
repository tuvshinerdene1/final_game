extends Node3D

@onready var anim: AnimationPlayer = $AnimationPlayer
@export_enum("Male", "Female") var gender: String = "Male"

var is_being_shined_on: bool = false

func _ready() -> void:
	play_default()

func play_default():
	if gender == "Male":
		anim.play("male_default")
	else:
		anim.play("female_default")

func play_shut():
	if gender == "Male":
		anim.play("male_shut")
	else:
		anim.play("female_shut")

# This is called every frame by the player's RayCast
func shine_light():
	if not is_being_shined_on:
		is_being_shined_on = true
		play_shut()
	
	# Reset the timer/flag every frame the light hits
	# We will use the Player script to detect when this stops

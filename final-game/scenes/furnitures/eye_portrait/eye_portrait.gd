extends Node3D

@onready var anim: AnimationPlayer = $AnimationPlayer
@export_enum("Male", "Female") var gender: String = "Male"

var is_being_shined_on: bool = false

func _ready():
	#play_open()
	play_shut()

		
func toggle_eye():
	is_being_shined_on = not is_being_shined_on
	#if is_being_shined_on:
		#return
	if is_being_shined_on:
		play_shut()
	else:
		play_open()
		
func play_shut():
	if gender == "Male":
		anim.play("male_shut")
	else:
		anim.play("female_shut")

func play_open():
	if gender == "Male":
		anim.play("male_open")
	else:
		anim.play("female_open")

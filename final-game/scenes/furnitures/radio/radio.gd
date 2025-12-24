extends Node3D

# The "Creepy/Story" audio (plays once when you get close)
@export var audio_name : AudioStream = null
# The "Static/Background" audio (loops after the first one finishes)
@export var default_name: AudioStream = null

# Reference to the player to calculate distance
#@onready var player: Node3D = get_parent().get_parent().get_node("Player")
@onready var player: CharacterBody3D = $"../../Player"
@onready var audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D

# State variables
var has_triggered = false
var is_looping_stage = false


func _ready() -> void:
	# Don't play anything at the start. We wait for the player.
	audio_player.stop()
	
	# Connect the signal for when audio finishes
	if not audio_player.finished.is_connected(_on_audio_finished):
		audio_player.finished.connect(_on_audio_finished)
	if player != null:
		print("player is not null")
		
func _process(_delta: float) -> void:
	# If we have already triggered the radio, stop checking distance to save performance
	if has_triggered:
		return

	# Ensure player and audio_player exist before checking
	if player and audio_player:
		# Calculate distance between Radio and Player
		var dist = global_position.distance_to(player.global_position)
		
		# Check if inside the max_distance
		if dist <= audio_player.max_distance:
			_start_broadcast()

func _start_broadcast() -> void:
	has_triggered = true
	
	if audio_name:
		# Play the Intro (Creepy Audio)
		audio_player.stream = audio_name
		audio_player.play()
	elif default_name:
		# If no intro exists, skip straight to loop
		_play_loop()

func _on_audio_finished() -> void:
	# If we haven't reached the loop stage yet, that means the Intro just finished.
	if not is_looping_stage:
		_play_loop()
	else:
		# We are already in the loop stage. 
		# If the audio file itself isn't set to "Loop" in Import settings,
		# this forces it to play again immediately.
		audio_player.play()

func _play_loop() -> void:
	if default_name:
		is_looping_stage = true
		audio_player.stream = default_name
		audio_player.play()

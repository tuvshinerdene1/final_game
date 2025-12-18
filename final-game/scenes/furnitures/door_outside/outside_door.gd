extends Node3D

@onready var anim = $StaticBody3D/AnimationPlayer
@onready var interact_zone = $StaticBody3D/Area3D
@onready var audio_player = $StaticBody3D/AudioStreamPlayer3D

@export var open_sound: AudioStream
@export var close_sound: AudioStream
@export var locked_sound: AudioStream
@export var unlock_sound : AudioStream
@export var locked_with_key : bool = false

var is_open: bool = false
var player_in_range: bool = false
var player_ref : Node3D = null
var last_played_anim: String = ""


func _ready():
	# Connect the Area3D signals via code (or do it in the editor)
	interact_zone.body_entered.connect(_on_body_entered)
	interact_zone.body_exited.connect(_on_body_exited)

func _process(delta):
	# If player is close AND presses 'E'
	if player_in_range and Input.is_action_just_pressed("interact"):
		if not anim.is_playing(): # prevent spamming while moving
			toggle_door()

func toggle_door():
	if locked_with_key:
		handle_lock()
		return
	if is_open:
		close_door()
	else:
		open_door()
		
func try_door():
	anim.play("locked")
	audio_player.stream = locked_sound
	audio_player.play()
	
func handle_lock():
	if player_ref.has_key:
		audio_player.stream = unlock_sound
		audio_player.play()
		player_ref.has_key = false
		open_door()
	else:
		try_door()
		
		
func open_door():
	#1 get the direction of door facing (global z axis)
	var door_forward = global_transform.basis.z
	
	#2 get the vector direction to the player
	var direction_to_player = global_position.direction_to(player_ref.global_position)
	
	#3 calculate dot product 
	var dot_product = door_forward.dot(direction_to_player)
	
	#4 decide which animation to play
	if dot_product > 0 :
		anim.play("open_reverse")
		last_played_anim = "open_reverse"
	else:
		anim.play("open")
		last_played_anim = "open"
		
	if open_sound:
		audio_player.stream = open_sound
		audio_player.pitch_scale = randf_range(0.9, 1.1)
		audio_player.play()
	is_open = true

func close_door():
	if last_played_anim != "":
		anim.play_backwards(last_played_anim)
	
	if close_sound:
		audio_player.stream = close_sound
		audio_player.pitch_scale = randf_range(0.9, 1.1)
		audio_player.play()
	is_open = false

# Signal: Player walked into the invisible bubble
func _on_body_entered(body):
	if body.name == "Player": # Or use groups: if body.is_in_group("player")
		player_in_range = true
		player_ref = body
		# Optional: Show a UI message like "Press E" here

# Signal: Player walked away
func _on_body_exited(body):
	if body.name == "Player":
		player_in_range = false
		player_ref = null
		# Optional: Hide the UI message here

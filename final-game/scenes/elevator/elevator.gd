extends Node3D

@onready var animation_player :AnimationPlayer =  $AnimationPlayer
@onready var button_interact : Area3D = $button_interact_area
@onready var sound_player: AudioStreamPlayer3D = $open_close_sound

@export var sound_open : AudioStream = null
@export var sound_close : AudioStream = null

var is_open: bool = true
var player_in_range: bool = false
var player_ref : Node3D = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button_interact.body_entered.connect(_on_body_entered)
	button_interact.body_exited.connect(_on_body_exited)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player_in_range and Input.is_action_just_pressed("interact"):
		if not animation_player.is_playing(): # prevent spamming while moving
			toggle_door()

func _on_body_entered(body):
	if body.name == "Player":
		player_in_range = true
		player_ref = body

func _on_body_exited(body):
	if body.name == "Player":
		player_in_range = false
		player_ref = null
func toggle_door():
	if is_open:
		close_door()
	else:
		open_door()

func close_door():
	animation_player.play("open")
	is_open = false
	if sound_close:
		sound_player.stream = sound_close
		sound_player.pitch_scale = randf_range(0.9, 1.1)
		sound_player.play()
		
func open_door():
	animation_player.play_backwards("open")
	is_open = true
	if sound_open:
		sound_player.stream = sound_open
		sound_player.pitch_scale = randf_range(0.9,1.2)
		sound_player.play()

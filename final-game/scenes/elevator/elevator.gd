extends Node3D

@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var button_interact : Area3D = $button_interact_area
@onready var sound_player: AudioStreamPlayer3D = $open_close_sound

@export var sound_open : AudioStream = null
@export var sound_close : AudioStream = null

# Using a SETTER: This runs the moment the Corridor script changes the variable
@export var perma_closed: bool = false:
	set(value):
		perma_closed = value
		if is_node_ready() and perma_closed:
			close_door()

var is_open: bool = true
var player_in_range: bool = false
var player_ref : Node3D = null

func _ready() -> void:
	# If it's permanently closed, force it shut and don't connect signals
	if perma_closed:
		close_door()
	
	# We still connect signals, but we will check the variable before allowing interaction
	button_interact.body_entered.connect(_on_body_entered)
	button_interact.body_exited.connect(_on_body_exited)

func _process(_delta: float) -> void:
	# Add 'not perma_closed' here to prevent the interact key from working
	if player_in_range and not perma_closed and Input.is_action_just_pressed("interact"):
		if not animation_player.is_playing():
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
	if perma_closed: return # Safety check
	
	if is_open:
		close_door()
	else:
		open_door()

func close_door():
	# Assuming "open" is the name of your animation that covers the door movement
	animation_player.play("open") 
	is_open = false
	if sound_close:
		sound_player.stream = sound_close
		sound_player.pitch_scale = randf_range(0.9, 1.1)
		sound_player.play()
		
func open_door():
	if perma_closed: return # Prevent opening if locked
	animation_player.play_backwards("open")
	is_open = true
	if sound_open:
		sound_player.stream = sound_open
		sound_player.pitch_scale = randf_range(0.9, 1.2)
		sound_player.play()

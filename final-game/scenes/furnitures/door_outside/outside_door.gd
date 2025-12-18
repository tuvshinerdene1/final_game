extends Node3D

@onready var anim = $StaticBody3D/AnimationPlayer
@onready var interact_zone = $StaticBody3D/Area3D
@onready var audio_player = $StaticBody3D/AudioStreamPlayer3D

@export var open_sound: AudioStream
@export var close_sound: AudioStream
@export var locked_sound: AudioStream
@export var unlock_sound : AudioStream
@export var locked_with_key : bool = false
@export var perma_locked : bool = false

var is_open: bool = false
var player_in_range: bool = false
var player_ref : Node3D = null
var last_played_anim: String = ""

# New variables for the permanent lock logic
var is_permanently_locked: bool = false
var trap_area: Area3D = null

func _ready():
	interact_zone.body_entered.connect(_on_body_entered)
	interact_zone.body_exited.connect(_on_body_exited)

func _process(_delta):
	# Stop processing interaction if the door is permanently locked
	if is_permanently_locked: return
	if perma_locked: return
	
	if player_in_range and Input.is_action_just_pressed("interact"):
		if not anim.is_playing():
			toggle_door()

func toggle_door():
	if locked_with_key:
		handle_lock()
		return
	if is_open:
		close_door()
	else:
		open_door()

func open_door():
	var door_forward = global_transform.basis.z
	var direction_to_player = global_position.direction_to(player_ref.global_position)
	var dot_product = door_forward.dot(direction_to_player)
	
	if dot_product > 0:
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
	
	# NEW: Create the trap area once the door is opened for the first time
	if not is_permanently_locked:
		create_trap_area(dot_product)

func create_trap_area(dot_product: float):
	# If a trap already exists, don't make another
	if trap_area: return
	
	trap_area = Area3D.new()
	var collision = CollisionShape3D.new()
	var box = BoxShape3D.new()
	
	box.size = Vector3(2, 2, 2) # Adjust size as needed
	collision.shape = box
	trap_area.add_child(collision)
	add_child(trap_area)
	
	# Position the area: If dot > 0, player is in FRONT, so place trap BEHIND (negative Z)
	# If dot < 0, player is BEHIND, so place trap in FRONT (positive Z)
	var offset_distance = 2.0
	var side = -1.0 if dot_product > 0 else 1.0
	trap_area.position = Vector3(0, 1, side * offset_distance)
	
	trap_area.body_entered.connect(_on_trap_entered)

func _on_trap_entered(body):
	if body == player_ref and is_open:
		lock_door_permanently()

func lock_door_permanently():
	is_permanently_locked = true
	close_door()
	# Clean up the trap area
	if trap_area:
		trap_area.queue_free()
	print("The door has slammed shut and is now jammed!")

# --- Rest of your existing functions ---

func handle_lock():
	if player_ref.has_key:
		audio_player.stream = unlock_sound
		audio_player.play()
		player_ref.has_key = false
		locked_with_key = false # Unlock the key requirement
		open_door()
	else:
		try_door()

func try_door():
	anim.play("locked")
	audio_player.stream = locked_sound
	audio_player.play()

func close_door():
	if last_played_anim != "":
		anim.play_backwards(last_played_anim)
	
	if close_sound:
		audio_player.stream = close_sound
		audio_player.pitch_scale = randf_range(0.9, 1.1)
		audio_player.play()
	is_open = false

func _on_body_entered(body):
	if body.name == "Player":
		player_in_range = true
		player_ref = body

func _on_body_exited(body):
	if body.name == "Player":
		player_in_range = false
		player_ref = null

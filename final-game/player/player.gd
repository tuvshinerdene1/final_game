extends CharacterBody3D

@export var mouse_sensitivity: float = 0.002
@export var SPEED: float = 1.5
@export var JUMP_VELOCITY: float = 4.5

# Headbob settings
@export var HEADBOB_ENABLED := true
@export var HEADBOB_FREQUENCY := 1.8  # Slower, more deliberate
@export var HEADBOB_AMPLITUDE := 0.03  # Vertical movement
@export var HEADBOB_SWAY_AMOUNT := 0.02  # Horizontal sway

# Head sway settings (for standing still and subtle movement)
@export var IDLE_SWAY_ENABLED := true
@export var IDLE_SWAY_FREQUENCY := 1.0
@export var IDLE_SWAY_AMPLITUDE := 0.015

# Camera tilt when moving sideways
@export var MOVEMENT_TILT_AMOUNT := 0.05

# ---------- FOOTSTEP SETTINGS ----------
@export var MIN_WALK_SPEED: float = 0.2          # how fast you must move before walking sound starts
@export var walking_loops: Array[AudioStream] = []  # assign your 4 walking sounds in the editor
# ---------------------------------------

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var camera: Camera3D = $Camera3D

# ---------- FOOTSTEP NODE ----------
@onready var footstep_player: AudioStreamPlayer3D = $FootstepPlayer
# -----------------------------------

# Head bob vars
var headbob_time: float = 0.0
var idle_sway_time: float = 0.0
var original_camera_position: Vector3
var original_camera_rotation: Vector3

var direction: Vector3 = Vector3.ZERO

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	original_camera_position = camera.position
	original_camera_rotation = camera.rotation
	camera.current = true


func _input(event) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, -1.2, 1.2)

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	move()
	apply_headbob_and_sway(delta)

	_update_walking_sound()  

	move_and_slide()

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

func move() -> void:
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction != Vector3.ZERO:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

func apply_headbob_and_sway(delta: float) -> void:
	var horizontal_velocity := Vector2(velocity.x, velocity.z)
	var is_moving := horizontal_velocity.length() > 0.1 and is_on_floor()

	var target_position: Vector3 = original_camera_position
	var target_rotation: Vector3 = Vector3.ZERO  # local rotation offset

	if is_moving and HEADBOB_ENABLED and SPEED > 0.0:
		# Walking headbob
		headbob_time += delta * horizontal_velocity.length() / SPEED
		idle_sway_time = 0.0  # Reset idle sway when moving

		# Vertical bob (up and down)
		target_position.y += sin(headbob_time * HEADBOB_FREQUENCY * TAU) * HEADBOB_AMPLITUDE

		# Horizontal sway (side to side)
		target_position.x += cos(headbob_time * HEADBOB_FREQUENCY * TAU * 0.5) * HEADBOB_SWAY_AMOUNT

		# Slight camera tilt based on horizontal movement
		var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
		target_rotation.z = -input_dir.x * MOVEMENT_TILT_AMOUNT
	else:
		# Idle breathing/sway effect
		if IDLE_SWAY_ENABLED:
			idle_sway_time += delta

			# Very subtle breathing motion
			target_position.y += sin(idle_sway_time * IDLE_SWAY_FREQUENCY * TAU) * IDLE_SWAY_AMPLITUDE * 0.5
			target_position.x += cos(idle_sway_time * IDLE_SWAY_FREQUENCY * TAU * 0.7) * IDLE_SWAY_AMPLITUDE * 0.3

		# Reset headbob time when not moving
		headbob_time = 0.0

	# Smoothly interpolate to target position and rotation
	var lerp_speed := 10.0 if is_moving else 5.0
	camera.position = camera.position.lerp(target_position, delta * lerp_speed)

	# Apply rotation tilt (separate from mouse look rotation)
	var current_local_rotation := Vector3(0.0, 0.0, camera.rotation.z)
	var new_local_rotation := current_local_rotation.lerp(target_rotation, delta * lerp_speed)
	camera.rotation.z = new_local_rotation.z


# ==========================
# WALKING LOOP SOUND LOGIC
# ==========================

func _is_walking() -> bool:
	var horizontal_speed := Vector2(velocity.x, velocity.z).length()
	return horizontal_speed > MIN_WALK_SPEED and is_on_floor()

func _update_walking_sound() -> void:
	var walking := _is_walking()

	if walking:

		# If not already playing, start a random loop
		if not footstep_player.playing:
			footstep_player.play()
	else:
		# Stop the sound when you stop walking or leave the floor
		if footstep_player.playing:
			footstep_player.stop()

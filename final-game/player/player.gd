extends CharacterBody3D

@export var mouse_sensitivity : float = 0.002
@export var SPEED = 5.0
@export var JUMP_VELOCITY = 4.5
@export var HEADBOB = true
@export var HEADBOB_FREQUENCY = 0.5
@export var HEADBOB_DISTANCE = 0.2

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var camera: Camera3D = $Camera3D

# Head bob vars
var bob_time: float = 0.0
var original_position: Vector3
var bob_target: float = 0.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	original_position = camera.position

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, -1.2, 1.2)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump (bonus: you had the var but not the code)
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

	# Head bob implementation
	if HEADBOB:
		var hspeed: float = Vector2(velocity.x, velocity.z).length()
		if is_on_floor():
			if hspeed > 0.1:
				bob_time += delta * hspeed * HEADBOB_FREQUENCY
				bob_target = sin(bob_time) * HEADBOB_DISTANCE
			else:
				bob_target = 0.0
				bob_time = 0.0  # Reset phase when stopping
		else:
			bob_target = 0.0  # No bob in air

		# Smoothly lerp to target bob
		var target_y = original_position.y + bob_target
		camera.position.y = lerp(camera.position.y, target_y, 12.0 * delta)
	else:
		camera.position.y = lerp(camera.position.y, original_position.y, 12.0 * delta)

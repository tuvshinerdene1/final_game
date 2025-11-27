extends CharacterBody3D

@export var mouse_sensitivity : float = 0.002
@export var SPEED = 5.0
@export var JUMP_VELOCITY = 4.5
@export var HEADBOB := true
@export var HEADBOB_FREQUENCY = 2.0
@export var HEADBOB_DISTANCE = 0.05

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var camera: Camera3D = $Camera3D

# Head bob vars
var bob_time: float = 0.0
var original_position: Vector3

var direction:Vector3 = Vector3.ZERO

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	original_position = camera.position

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, -1.2, 1.2)

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	move()
	move_and_slide()

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y -= gravity*delta

func move():
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction != Vector3.ZERO:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		headbob()
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

func headbob():
	if not HEADBOB:
		# Reset to original position if headbob is disabled mid-game
		camera.position = camera.position.lerp(original_position, 20.0 * get_physics_process_delta_time())
		bob_time = 0.0
		print("not bobbing")
		return
	
	var horizontal_speed = Vector2(velocity.x, velocity.z).length()
	
	if is_on_floor() and horizontal_speed > 0:
		var speed_factor = horizontal_speed / SPEED
		var current_frequency = HEADBOB_FREQUENCY * speed_factor
		
		bob_time += get_physics_process_delta_time() * current_frequency * 2.0
		
		var vertical_bob = sin(bob_time) * HEADBOB_DISTANCE * speed_factor
		var horizontal_bob = sin(bob_time * 0.5) * HEADBOB_DISTANCE * 0.4 * speed_factor  # subtle side-to-side
		
		camera.position.y = original_position.y + vertical_bob
		camera.position.x = original_position.x + horizontal_bob
		print("doing head bobbing")
	else:
		camera.position.y = lerpf(camera.position.y, original_position.y, 12.0 * get_physics_process_delta_time())
		camera.position.x = lerpf(camera.position.x, original_position.x, 12.0 * get_physics_process_delta_time())
		bob_time = lerp(bob_time, 0.0, 8.0 * get_physics_process_delta_time())
	move_and_slide()

extends StaticBody3D

@onready var anim = $AnimationPlayer
@onready var interact_zone = $Area3D

var is_open: bool = false
var player_in_range: bool = false

func _ready():
	# Connect the Area3D signals via code (or do it in the editor)
	interact_zone.body_entered.connect(_on_body_entered)
	interact_zone.body_exited.connect(_on_body_exited)

func _process(delta):
	# If player is close AND presses 'E'
	if player_in_range and Input.is_action_just_pressed("interact"):
		toggle_door()

func toggle_door():
	if is_open:
		# Close the door
		anim.play_backwards("open")
		is_open = false
	else:
		# Open the door
		anim.play("open")
		is_open = true

# Signal: Player walked into the invisible bubble
func _on_body_entered(body):
	if body.name == "Player": # Or use groups: if body.is_in_group("player")
		player_in_range = true
		# Optional: Show a UI message like "Press E" here

# Signal: Player walked away
func _on_body_exited(body):
	if body.name == "Player":
		player_in_range = false
		# Optional: Hide the UI message here

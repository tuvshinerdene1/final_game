extends Node3D

@onready var area : Area3D = $Area3D
@onready var audio_player : AudioStreamPlayer3D = $AudioStreamPlayer3D

@export var document_info : DocumentData = null
@export var sound_pickup : AudioStream = null
@export var sound_putdown: AudioStream = null

var is_player_in_range: bool = false
var is_reading : bool = false
var player_ref : Node3D = null
var ui_reference = null # We will store the UI here

func _ready() -> void:
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)
	
	# Find the UI in the scene tree
	ui_reference = get_tree().get_first_node_in_group("DocumentUI")
	if ui_reference:
		# Listen for when the UI closes itself (via button press)
		ui_reference.on_close_document.connect(put_down)

func _process(delta: float) -> void:
	# Only allow opening if in range and NOT already reading
	# (Closing is handled by the UI or the UI input check)
	if is_player_in_range and Input.is_action_just_pressed("interact") and not is_reading:
		read()

func _on_body_entered(body):
	if body.name == "Player": 
		is_player_in_range = true
		player_ref = body

func _on_body_exited(body):
	if body.name == "Player":
		is_player_in_range = false
		player_ref = null
		# If we walk away while reading, force close
		if is_reading:
			put_down()

func read():
	if not ui_reference:
		printerr("Document UI not found! Check Groups.")
		return
		
	is_reading = true
	
	# Audio
	if sound_pickup:
		audio_player.stream = sound_pickup
		audio_player.play()
	
	# Pause Game
	Engine.time_scale = 0
	
	# Open UI
	ui_reference.open_document(document_info)

func put_down():
	# This function acts as the "cleanup"
	is_reading = false
	
	# Audio
	if sound_putdown:
		audio_player.stream = sound_putdown
		audio_player.play()
	
	# Resume Game
	Engine.time_scale = 1
	
	# Ensure UI is actually closed (in case put_down was called by walking away)
	if ui_reference and ui_reference.visible:
		ui_reference.close_document()

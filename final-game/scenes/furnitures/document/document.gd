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
	ui_reference = get_tree().get_first_node_in_group("DocumentUI")
	if ui_reference:
		ui_reference.on_close_document.connect(put_down)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		if is_reading:
			put_down()
		elif is_player_in_range:
			read()

func _on_body_entered(body):
	if body.name == "Player": 
		is_player_in_range = true
		player_ref = body

func _on_body_exited(body):
	if body.name == "Player":
		is_player_in_range = false
		player_ref = null
		if is_reading:
			put_down()

func read():
	if not ui_reference:
		printerr("Document UI not found! Check Groups.")
		return
		
	is_reading = true
	
	if sound_pickup:
		audio_player.stream = sound_pickup
		audio_player.play()
		
	Engine.time_scale = 0
	ui_reference.open_document(document_info)

func put_down():
	is_reading = false
	
	if sound_putdown:
		audio_player.stream = sound_putdown
		audio_player.play()
	
	Engine.time_scale = 1
	
	if ui_reference and ui_reference.visible:
		ui_reference.close_document()

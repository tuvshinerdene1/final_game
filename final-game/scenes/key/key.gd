extends Node3D

signal key_picked_up


@onready var player_range: Area3D = $Area3D
@onready var audio:AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var model = $Sketchfab_Scene
@onready var light = $OmniLight3D

var is_player_in_range: bool = false
var is_picked_up: bool = false


func _ready() -> void:
	player_range.body_entered.connect(_on_body_entered)
	player_range.body_exited.connect(_on_body_exited)

func _process(delta: float) -> void:
	if is_player_in_range and Input.is_action_just_pressed("interact"):
		pick_up()
	
func _on_body_entered(body):
	if body.name == "Player": 
		is_player_in_range = true
		if not key_picked_up.is_connected(body._on_key_picked_up):
			key_picked_up.connect(body._on_key_picked_up)

func _on_body_exited(body):
	if body.name == "Player":
		is_player_in_range = false

func pick_up():
	key_picked_up.emit()
	audio.play()
	light.hide()
	model.hide()
	await audio.finished
	delete_node()
	
func delete_node():
	queue_free()

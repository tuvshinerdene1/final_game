extends Area3D

@export var hear_radius: float = 120.0
@export var silence_radius: float = 1.0

@onready var audio: AudioStreamPlayer3D = $"../AudioStreamPlayer3D"
@onready var shape: SphereShape3D = $CollisionShape3D.shape

var player: Node3D = null
var armed := true # can trigger only once

func _ready():
	shape.radius = hear_radius
	audio.max_distance = hear_radius
	audio.autoplay = false
	audio.stop()

	body_entered.connect(_on_enter)
	body_exited.connect(_on_exit)

func _physics_process(_delta):
	if !armed or player == null:
		return

	var d := global_position.distance_to(player.global_position)

	# If player reached the “destination” (2m), stop forever
	if d <= silence_radius:
		_stop_forever()

func _on_enter(body: Node) -> void:
	if !armed:
		return
	if body.is_in_group("player"):
		player = body as Node3D
		# start lure sound
		audio.volume_db = -40
		audio.play()
		create_tween().tween_property(audio, "volume_db", 0.0, 1.0)

func _on_exit(body: Node) -> void:
	if body == player:
		player = null
		# if they leave without reaching 2m, stop (but can trigger again until completed)
		if armed and audio.playing:
			var t := create_tween()
			t.tween_property(audio, "volume_db", -40.0, 0.5)
			t.finished.connect(func(): audio.stop())

func _stop_forever() -> void:
	armed = false

	# Fade out then stop
	var t := create_tween()
	t.tween_property(audio, "volume_db", -40.0, 0.6)
	t.finished.connect(func():
		audio.stop()
	)

	# Disable the trigger so it never plays again
	monitoring = false
	monitorable = false
	$CollisionShape3D.disabled = true
	set_physics_process(false)

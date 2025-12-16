extends Control

@onready var title_label: Label = $TitleLabel
@onready var press_any_key_label: Label = $PressAnyKeyLabel
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var audio_intro: AudioStreamPlayer = $AudioIntro

var can_continue := false
var has_started_transition := false

func _ready() -> void:
	# Play spooky intro
	if audio_intro.stream:
		audio_intro.play()
	press_any_key_label.visible = false
	can_continue = false
	has_started_transition = false

func _create_title_fade_animation() -> void:
	var a := Animation.new()
	a.length = 2.0
	var track := a.add_track(Animation.TYPE_VALUE)
	a.track_insert_key(track, 0.0, Color(1, 1, 1, 0))
	a.track_insert_key(track, 2.0, Color(1, 1, 1, 1))
	#anim.add_animation("title_fade_in", a)

func _on_Timer_timeout() -> void:
	# Only allow input after the delay – no scene change here
	press_any_key_label.visible = true
	can_continue = true

func _unhandled_input(event: InputEvent) -> void:
	if not can_continue or has_started_transition:
		return

	if event is InputEventKey \
		or event is InputEventMouseButton \
		or event is InputEventJoypadButton:
		has_started_transition = true
		_go_to_main_menu()

func _go_to_main_menu() -> void:
	# Fade out sound then change scene
	if audio_intro.playing:
		var tween := create_tween()
		tween.tween_property(audio_intro, "volume_db", -40.0, 0.8)
		tween.tween_callback(Callable(self, "_change_scene_to_menu"))
	else:
		_change_scene_to_menu()

func _change_scene_to_menu() -> void:
	get_tree().change_scene_to_file("res://horror_ui_ui_scenes/ui/MainMenu.tscn")

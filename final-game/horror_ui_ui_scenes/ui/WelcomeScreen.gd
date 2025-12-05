extends Control

@onready var title_label: Label = $TitleLabel
@onready var press_any_key_label: Label = $PressAnyKeyLabel
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var delay_timer: Timer = $Timer

var can_continue := false

func _ready() -> void:
	if anim.has_animation("title_intro"):
		anim.play("title_intro")
	press_any_key_label.visible = false
	can_continue = false

func _on_Timer_timeout() -> void:
	press_any_key_label.visible = true
	can_continue = true
	if anim.has_animation("press_flicker"):
		anim.play("press_flicker")

func _unhandled_input(event: InputEvent) -> void:
	if not can_continue:
		return
	if event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton:
		_go_to_main_menu()

func _go_to_main_menu() -> void:
	get_tree().change_scene_to_file("res://horror_ui_ui_scenes/ui/MainMenu.tscn")

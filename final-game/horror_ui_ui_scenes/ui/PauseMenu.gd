extends CanvasLayer

signal resume_requested
signal back_to_main_menu_requested

@onready var root: Control = $Root
@onready var resume_button: Button = $Root/Panel/VBoxContainer/ResumeButton
@onready var settings_button: Button = $Root/Panel/VBoxContainer/SettingsButton
@onready var main_menu_button: Button = $Root/Panel/VBoxContainer/MainMenuButton

func _ready() -> void:
	visible = false
	resume_button.pressed.connect(_on_resume_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)

func open() -> void:
	visible = true
	get_tree().paused = true

func close() -> void:
	visible = false
	get_tree().paused = false

func toggle() -> void:
	if visible:
		close()
	else:
		open()

func _on_resume_pressed() -> void:
	close()
	resume_requested.emit()

func _on_settings_pressed() -> void:
	# TODO: implement settings popup
	pass

func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	back_to_main_menu_requested.emit()
	get_tree().change_scene_to_file("res://horror_ui_ui_scenes/ui/MainMenu.tscn")

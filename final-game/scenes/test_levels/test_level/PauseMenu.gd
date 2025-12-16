extends CanvasLayer

signal resume_requested
signal back_to_main_menu_requested

@onready var root: Control = $Root
@onready var resume_button: Button = $Root/Panel/VBoxContainer/ResumeButton
@onready var settings_button: Button = $Root/Panel/VBoxContainer/SettingsButton
@onready var main_menu_button: Button = $Root/Panel/VBoxContainer/MainMenuButton

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS  # Process even when paused
	visible = false
	
	resume_button.pressed.connect(_on_resume_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)

# Use _unhandled_key_input for higher priority blocking
func _unhandled_key_input(event: InputEvent) -> void:
	if visible and event.keycode != KEY_ESCAPE:
		get_viewport().set_input_as_handled()

# Block mouse input
func _input(event: InputEvent) -> void:
	if visible:
		if event is InputEventMouseMotion:
			get_viewport().set_input_as_handled()
		elif event is InputEventMouseButton and not _is_mouse_over_ui():
			get_viewport().set_input_as_handled()

func _is_mouse_over_ui() -> bool:
	var mouse_pos = get_viewport().get_mouse_position()
	return root.get_global_rect().has_point(mouse_pos)

func open() -> void:
	visible = true
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func close() -> void:
	visible = false
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func toggle() -> void:
	if visible:
		close()
	else:
		open()

func _on_resume_pressed() -> void:
	close()
	resume_requested.emit()

func _on_settings_pressed() -> void:
	pass

func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	back_to_main_menu_requested.emit()
	get_tree().change_scene_to_file("res://test_level/MainMenu.tscn")

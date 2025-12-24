extends Node3D

@onready var pause_menu: CanvasLayer = $PauseMenu

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	pause_menu.resume_requested.connect(_on_pause_menu_resume_requested)
	pause_menu.back_to_main_menu_requested.connect(_on_pause_menu_back_to_main_menu_requested)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		pause_menu.toggle()
		get_viewport().set_input_as_handled()

func _on_pause_menu_resume_requested() -> void:
	print("Resume requested")

func _on_pause_menu_back_to_main_menu_requested() -> void:
	print("Back to main menu requested")

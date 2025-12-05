extends Control

@onready var new_game_button: Button = $MenuContainer/NewGameButton
@onready var load_game_button: Button = $MenuContainer/LoadGameButton
@onready var settings_button: Button = $MenuContainer/SettingsButton
@onready var quit_button: Button = $MenuContainer/QuitButton

func _ready() -> void:
	new_game_button.pressed.connect(_on_new_game_pressed)
	load_game_button.pressed.connect(_on_load_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_new_game_pressed() -> void:
	get_tree().change_scene_to_file("res://test_level_1/TestLevel1.tscn")
	
func _on_load_pressed() -> void:
	get_tree().change_scene_to_file("res://test_level_1/TestLevel1.tscn")

func _on_settings_pressed() -> void:
	pass

func _on_quit_pressed() -> void:
	get_tree().quit()

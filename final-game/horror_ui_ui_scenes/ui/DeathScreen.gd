extends CanvasLayer

@onready var root: Control = $Root
@onready var message_label: Label = $Root/MessageLabel
@onready var buttons_vbox: VBoxContainer = $Root/ButtonsVBox
@onready var delay_timer: Timer = $Root/DelayTimer
@onready var retry_button: Button = $Root/ButtonsVBox/RetryButton
@onready var main_menu_button: Button = $Root/ButtonsVBox/MainMenuButton

var last_level_path: String = "res://scenes/test_level_1/TestLevel1.tscn"

func _ready() -> void:
	visible = false
	buttons_vbox.visible = false
	delay_timer.timeout.connect(_on_DelayTimer_timeout)
	retry_button.pressed.connect(_on_retry_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)

func show_death(message: String = "you failed again.", level_path: String = "") -> void:
	if level_path != "":
		last_level_path = level_path
	message_label.text = message
	visible = true
	buttons_vbox.visible = false
	delay_timer.start()

func _on_DelayTimer_timeout() -> void:
	buttons_vbox.visible = true

func _on_retry_pressed() -> void:
	get_tree().change_scene_to_file(last_level_path)

func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://horror_ui_ui_scenes/ui/MainMenu.tscn")

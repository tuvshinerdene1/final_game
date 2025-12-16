extends CanvasLayer

@onready var root: Control = $Root
@onready var objective_label: Label = $Root/ObjectiveLabel
@onready var interaction_container: HBoxContainer = $Root/InteractionContainer
@onready var interaction_label: Label = $Root/InteractionContainer/InteractionLabel
@onready var interaction_dot: TextureRect = $Root/InteractionContainer/InteractionDot
@onready var vignette_overlay: ColorRect = $Root/VignetteOverlay

func _ready() -> void:
	interaction_container.visible = false
	objective_label.visible = false
	vignette_overlay.visible = false

func show_objective(text: String, duration: float = 3.0) -> void:
	objective_label.text = text
	objective_label.visible = true
	if duration > 0:
		_fade_out_objective(duration)

func _fade_out_objective(duration: float) -> void:
	await get_tree().create_timer(duration).timeout
	objective_label.visible = false

func show_interaction(prompt: String) -> void:
	interaction_label.text = prompt
	interaction_container.visible = true

func hide_interaction() -> void:
	interaction_container.visible = false

func set_danger_mode(enabled: bool) -> void:
	vignette_overlay.visible = enabled

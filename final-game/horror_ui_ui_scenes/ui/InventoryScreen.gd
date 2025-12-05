extends CanvasLayer

@onready var root: Control = $Root
@onready var items_grid: GridContainer = $Root/Panel/HBoxContainer/ItemsGrid
@onready var item_name_label: Label = $Root/Panel/HBoxContainer/DescriptionVBox/ItemNameLabel
@onready var item_description_label: Label = $Root/Panel/HBoxContainer/DescriptionVBox/ItemDescriptionLabel

var items: Array = []

func _ready() -> void:
	visible = false
	item_name_label.text = ""
	item_description_label.text = ""

func open() -> void:
	visible = true
	get_tree().paused = true
	_refresh_items()

func close() -> void:
	visible = false
	get_tree().paused = false

func toggle() -> void:
	if visible:
		close()
	else:
		open()

func _refresh_items() -> void:
	for child in items_grid.get_children():
		child.queue_free()

	for item in items:
		var btn := Button.new()
		btn.text = item.get("short_name", "???")
		btn.pressed.connect(_on_item_pressed.bind(item))
		items_grid.add_child(btn)

func _on_item_pressed(item: Dictionary) -> void:
	item_name_label.text = item.get("name", "Unknown")
	var base_desc := item.get("description", "")
	var alt_desc := item.get("alt_description", "")
	if alt_desc != "" and randf() < 0.25:
		item_description_label.text = alt_desc
	else:
		item_description_label.text = base_desc

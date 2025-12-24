extends CanvasLayer



func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	
@onready var title_label: Label =$Control/PaperBackground/TitleLabel
@onready var body_text: RichTextLabel =$Control/PaperBackground/BodyText
@onready var page_count_label: Label = $Control/PaperBackground/PageCountLabel
@onready var background_rect: TextureRect =$Control/PaperBackground
@onready var next_btn: Button = $Control/PaperBackground/NextButton
@onready var prev_btn: Button = $Control/PaperBackground/PrevButton
@onready var close_btn: Button = $Control/PaperBackground/CloseButton

var current_doc: DocumentData
var current_page_index: int = 0

signal on_close_document

func open_document(doc: DocumentData):
	current_doc = doc
	current_page_index = 0
	if doc.background:
		background_rect.texture = doc.background
	title_label.text = doc.title
	update_page()
	visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func update_page():
	if current_doc.pages.size() > 0:
		body_text.text = current_doc.pages[current_page_index]
	else:
		body_text.text = ""
		
	# Update "1 / 3" label
	page_count_label.text = str(current_page_index + 1) + " / " + str(current_doc.pages.size())
	
	# Enable/Disable buttons based on page count
	prev_btn.visible = current_page_index > 0
	next_btn.visible = current_page_index < current_doc.pages.size() - 1
# Called every frame. 'delta' is the elapsed time since the previous frame.



# Optional: Handle keyboard inputs for better feel
func _input(event: InputEvent) -> void:
	if not visible: return
	
	if event.is_action_pressed("ui_right"):
		_on_next_button_pressed()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_left"):
		_on_prev_button_pressed()

func close_document():
	visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	emit_signal("on_close_document")

func _on_next_button_pressed() -> void:
	if current_page_index < current_doc.pages.size() - 1:
		current_page_index += 1
		update_page()


func _on_prev_button_pressed() -> void:
	if current_page_index > 0:
		current_page_index -= 1
		update_page()


func _on_close_button_pressed() -> void:
	visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	emit_signal("on_close_document")

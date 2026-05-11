extends CanvasLayer

# TEXTBOX VARIABLES
const MAX_WIDTH = 520.0
const VERTICAL_OFFSET = -260.0
const PADDING = 16.0
const CHARS_PER_PAGE = 220
const BG_COLOR = Color(0.04, 0.04, 0.07, 0.88)

# FONT VARIABLES
const TEXT_COLOR = Color(0.82, 0.82, 0.82, 1.0)
var font_path = "res://assets/fonts/JetBrainsMono-VariableFont_wght.ttf"

# PAGINATION VARIABLES
var _pages: Array[String] = []
var _current_page: int = 0
var _container: PanelContainer
var _thought_label: Label
var _hint_label: Label

# TEXT STREAM VARIABLES
enum State {IDLE, STREAMING, READING}
const STREAM_SPEED: float = 38.0
var _state: State = State.IDLE
var _stream_tween: Tween = null

# Constructor. Build at startup.
# Basically, the textbox and text is ALWAYS pre-built,
# it's just the actual events in-game that make it visible.
func _ready() -> void:
	_build_ui()
	_container.visible = false

func _build_ui() -> void:
	_container = PanelContainer.new()
	_container.name = "ThoughtContainer"
	
	# Style the textbox.
	var style = StyleBoxFlat.new()
	style.bg_color = BG_COLOR
	style.corner_radius_top_left = 3
	style.corner_radius_top_right = 3
	style.corner_radius_bottom_left = 3
	style.corner_radius_bottom_right = 3
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.border_color = Color(0.15, 0.15, 0.2, 0.6)
	_container.add_theme_stylebox_override("panel", style)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left",   int(PADDING))
	margin.add_theme_constant_override("margin_right",  int(PADDING))
	margin.add_theme_constant_override("margin_top",    int(PADDING))
	margin.add_theme_constant_override("margin_bottom", int(PADDING))
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	
	# Create the text itself.
	_thought_label = Label.new()
	_thought_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_thought_label.custom_minimum_size = Vector2(MAX_WIDTH - PADDING * 2, 0.0)
	_thought_label.add_theme_color_override("font_color", TEXT_COLOR)
	_thought_label.add_theme_font_size_override("font_size", 17)
	
	# IMPORTANT: SET FONT.
	# The italics version of the font is a different .tff,
	# so if i ever make a different thought-vs-speech textboxes,
	# bear it in mind.
	if ResourceLoader.exists(font_path):
		var font = load(font_path)
		_thought_label.add_theme_font_override("font", font)
	
	# Create "Hint," the little "press to continue" text.
	_hint_label = Label.new()
	_hint_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5, 1.0))
	_hint_label.add_theme_font_size_override("font_size", 13)
	_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	if ResourceLoader.exists(font_path):
		var font = load(font_path)
		_hint_label.add_theme_font_override("font", font)
	
	# Instantiate textbox and texts.
	vbox.add_child(_thought_label)
	vbox.add_child(_hint_label)
	margin.add_child(vbox)
	_container.add_child(margin)
	add_child(_container)

# Display the actual text.
func show_text(text: String) -> void:
	# Textbox.
	_current_page = 0
	_container.visible = true

	# Pagination.
	_pages = _paginate(text)

	# Streaming
	_stream_page(0)

func hide_text() -> void:
	# Textbox.
	_container.visible = false

	# Pagination.
	_pages.clear()
	_current_page = 0

	# Streaming.
	_kill_stream()
	_state = State.IDLE

func is_open() -> bool:
	return _state != State.IDLE

# Text streaming.
func _stream_page(index: int) -> void:
	_state = State.STREAMING
	var page_text = _pages[index]
	# Set full text first then hide all characters before
	# the tween begins revealing them.
	_thought_label.text = page_text
	_thought_label.visible_characters = 0
	_hint_label.text = ""
	_kill_stream()

	var duration: float = float(page_text.length()) / STREAM_SPEED
	_stream_tween = create_tween()
	_stream_tween.tween_property(
		_thought_label, "visible_characters",
		page_text.length(), duration
	).set_trans(Tween.TRANS_LINEAR)
	var has_more: bool = index < _pages.size() - 1
	_stream_tween.tween_callback(_on_stream_finished.bind(has_more))

# Adds the final "next..." hint at the end.
func _on_stream_finished(has_more: bool) -> void:
	_state = State.READING
	_hint_label.text = "[Continue...]" if has_more else "[Dismiss]"

func _kill_stream() -> void:
	if _stream_tween and _stream_tween.is_valid():
		_stream_tween.kill()
	_stream_tween = null

# Pagination. This will split text into different
# clicks on the textbox.
func _paginate(text: String) -> Array[String]:
	var pages: Array[String] = []
	var words = text.split(" ")
	var current := ""
	for word in words:
		var candidate = current + ("" if current.is_empty() else " ") + word
		if candidate.length() > CHARS_PER_PAGE and not current.is_empty():
			pages.append(current.strip_edges())
			current = word
		else:
			current = candidate
	if not current.is_empty():
		pages.append(current.strip_edges())
	if pages.is_empty():
		pages.append("")
	return pages

func _process(_delta: float) -> void:
	if not _container.visible:
		return
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return

	# Track Sam.
	var screen_pos: Vector2 = get_viewport().get_canvas_transform() * player.global_position
	_container.position = Vector2(
		screen_pos.x - _container.size.x / 2.0,
		screen_pos.y + VERTICAL_OFFSET - _container.size.y
	)

# On keypress, reveal the textbox.
func _input(event: InputEvent) -> void:
	if _state == State.IDLE:
		return

	var clicked = event is InputEventMouseButton \
		and event.button_index == MOUSE_BUTTON_LEFT \
		and event.pressed

	var interacted = event.is_action_pressed("ui_interact")

	if clicked or interacted:
		# Consume the event so InteractionSystem doesn't also fire on the same click.
		get_viewport().set_input_as_handled()
		_advance()

func _advance() -> void:
	match _state:
		# Skip to full reveal without advancing pages yet.
		State.STREAMING:
			_kill_stream()
			_thought_label.visible_characters = -1
			var has_more: bool = _current_page < _pages.size() - 1
			_hint_label.text = "[Continue...]" if has_more else "[Dismiss]"
			_state = State.READING
		State.READING:
			if _current_page < _pages.size() - 1:
				_current_page += 1
				_stream_page(_current_page)
			else:
				hide_text()

extends CanvasLayer

# ICON ASSETS
const ICONS = {
	"examine": preload("res://assets/icons/examine.png"),
	"pickup": preload("res://assets/icons/pickup.png"),
	"mechanism": preload("res://assets/icons/mechanism.png"),
}

# DOT STYLE VARIABLES
const DOT_IDLE_SIZE = Vector2(10, 10)
const DOT_HOVER_SIZE = Vector2(40, 40)
const HINT_HOVER_SIZE = Vector2(60, 60)
const TWEEN_DURATION = 0.14
var _tween: Tween = null

# NODES
@onready var _dot: Panel = $CursorDot
@onready var _icon: TextureRect = $IconRect
@onready var _hint: Panel = $MultipleHint

func _ready() -> void:
	# Hide the computer's mouse pointer thing, 
	# replace it with our own.
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

	# Scale the dot cursor.
	_dot.size = DOT_IDLE_SIZE
	_hint.size = DOT_IDLE_SIZE

	# Icon and hint starts hidden.
	_icon.visible = false
	_hint.visible = false

	# Signal response. In theory, this is the ONLY place where animations are triggered.
	CursorState.state_changed.connect(_on_state_changed)

# Move the cursor visual to follow the actual mouse position.
func _process(_delta) -> void:
	var mouse_pos = get_viewport().get_mouse_position()

	# Keep the dot's CENTER on the mouse, regardless of size.
	_dot.global_position = mouse_pos - (_dot.size / 2.0)
	# Keep the icon centered.
	_icon.global_position = mouse_pos - (_icon.size / 2.0)
	# Center the two-circle hint.
	if _hint:
		_hint.global_position = mouse_pos - _hint.size / 2.0

func _on_state_changed(new_target: CursorState.Target, activity: CursorState.Activity) -> void:
	match new_target:
		CursorState.Target.INTERACTABLE:
			_enter_hover()
		CursorState.Target.IDLE:
			_exit_hover()
		CursorState.Target.MENU:
			# TODO: Menu cursor.
			pass

func _enter_hover() -> void:
	_kill_tween()
	_icon.visible = false # Hide icon during growing animation.

	_grow_tween(_dot, DOT_HOVER_SIZE)
	# Once the dot has grown to full size, show the icon inside.
	_tween.tween_callback(_show_icon)
	_tween.tween_callback(CursorState.settle)

func _exit_hover() -> void:
	_kill_tween()
	_icon.visible = false # Hide icon immediately on exit.

	# Hide the two-circle "hint" if it exists.
	if _hint.visible:
		_shrink_tween(_hint, DOT_IDLE_SIZE)
		_hint.visible = false

	_shrink_tween(_dot, DOT_IDLE_SIZE)
	_tween.tween_callback(CursorState.settle)

func _show_icon() -> void:
	var interactions = CursorState.current_interactions
	if interactions.is_empty():
		return

	# Show the default interaction icon.
	var primary_id = interactions[0]["id"]
	if ICONS.has(primary_id):
		_icon.texture = ICONS[primary_id]
		_icon.visible = true

	# If more than one interaction, add a second circle as hint.
	if interactions.size() > 1:
		_grow_tween(_hint, HINT_HOVER_SIZE)
		_hint.visible = true

func _kill_tween() -> void:
	if _tween and _tween.is_valid():
		_tween.kill()
	_tween = null

# Tweens
func _grow_tween(obj, size):
	_tween = create_tween()
	_tween.tween_property(obj, "size", size, TWEEN_DURATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _shrink_tween(obj, size):
	_tween = create_tween()
	_tween.tween_property(obj, "size", size, TWEEN_DURATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
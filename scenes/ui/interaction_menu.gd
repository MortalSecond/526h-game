extends CanvasLayer

# MENU VARIABLES
# How far each option button is from the center of the menu.
const RADIUS = 70.0
# The cords where LMB was held.
var _origin: Vector2 = Vector2.ZERO
# The interactable this menu was opened for.
var _target: Node = null
# All spawned option buttons.
var _buttons: Array = []
# Which button is currently highlighted by the cursor.
var _highlighted: int = -1

func open(target: Node, interactions: Array, screen_pos: Vector2) -> void:
	_target = target
	_origin = screen_pos
	_clear_buttons()
	
	var count = interactions.size()
	for i in count:
		var interaction = interactions[i]
		_spawn_button(i, count, interaction)

func close() -> void:
	_clear_buttons()
	_target = null
	_highlighted = -1

func get_highlighted_interaction() -> Dictionary:
	if _highlighted < 0 or _highlighted >= _buttons.size():
		return {}
	return _buttons[_highlighted].get_meta("interaction")

func _spawn_button(index: int, total: int, interaction: Dictionary) -> void:
	# Calculate this button's angle around the circle.
	# Starting at the top (-PI/2) and going clockwise.
	var angle = -PI / 2.0 + index * (TAU / total)
	var btn_offset = Vector2(cos(angle), sin(angle)) * RADIUS
	
	# Each button is a Control containing the same BG+icon composite
	# as the cursor, just larger and positioned around the circle.
	var button = Control.new()
	button.size = Vector2(64, 64)
	button.position = _origin + btn_offset - Vector2(32, 32)
	button.set_meta("interaction", interaction)
	button.set_meta("index", index)
	
	var bg = TextureRect.new()
	bg.texture = CursorManager.ICON_BG
	bg.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	bg.size = Vector2(56, 56)
	
	var icon = TextureRect.new()
	var icon_id = interaction.get("id", "")
	if CursorManager.ICONS.has(icon_id):
		icon.texture = CursorManager.ICONS[icon_id]
	icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	icon.size = Vector2(56, 56)
	
	button.add_child(bg)
	button.add_child(icon)
	add_child(button)
	_buttons.append(button)

func _process(_delta) -> void:
	if _buttons.is_empty():
		return
	
	# Determine which button the cursor is closest to.
	var mouse_pos = get_viewport().get_mouse_position()
	var closest_index = -1
	var closest_dist = 999999.0
	
	for i in _buttons.size():
		var btn_center = _buttons[i].position + Vector2(28, 28)
		var dist = mouse_pos.distance_to(btn_center)
		if dist < closest_dist:
			closest_dist = dist
			closest_index = i
	
	# Only highlight if the cursor is close to a button.
	if closest_dist < RADIUS:
		_set_highlighted(closest_index)
	else:
		_set_highlighted(-1)

func _set_highlighted(index: int) -> void:
	# Reset all buttons to normal appearance, then highlight the chosen one.
	for i in _buttons.size():
		_buttons[i].modulate = Color(1, 1, 1, 1)
	
	if index >= 0:
		_buttons[index].modulate = Color(1.4, 1.4, 1.4, 1)
	
	_highlighted = index

func _clear_buttons() -> void:
	for btn in _buttons:
		btn.queue_free()
	_buttons.clear()

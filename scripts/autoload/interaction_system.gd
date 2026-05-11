extends Node

# CURSOR VARIABLES
# The interactable currently under the cursor. Null if nothing is hovered.
var hovered: Node = null
# How long LMB must be held before the radial menu opens instead of
# executing the default action.
const HOLD_THRESHOLD = 0.35
# Tracks how long LMB has been held this press.
var _hold_timer: float = 0.0
var _lmb_held: bool = false

# MENU VARIABLES
# Whether we've already opened the radial this press.
var _radial_opened: bool = false

# EXAMINE GUARD
var _examine_pressed: bool = false

# Tell the cursor system to change the icon.
func set_hovered(obj: Node) -> void:
	hovered = obj
	CursorManager.set_hover(obj.get_interactions())

func clear_hovered() -> void:
	hovered = null
	CursorManager.set_idle()

func _update_cursor() -> void:
	if hovered == null:
		return
	# Get the primary interaction to determine which icon to show.
	var interactions = hovered.get_interactions()
	if interactions.is_empty():
		return

func _process(delta: float) -> void:
	if _lmb_held and hovered != null:
		_hold_timer += delta
		# Once hold threshold is reached and radial hasn't opened yet,
		# open the radial menu if this object has multiple options.
		if _hold_timer >= HOLD_THRESHOLD and not _radial_opened:
			_radial_opened = true
			var interactions = hovered.get_interactions()
			if interactions.size() > 1:
				# Open interaction menu.
				var screen_pos = get_viewport().get_mouse_position()
				InteractionMenu.open(hovered, interactions, screen_pos)
			else:
				# Single option, no menu.
				hovered.execute_interaction(interactions[0]["id"])

func _input(event: InputEvent) -> void:
	# Dismiss examine text first if it's open.
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if ExamineUI.is_open():
			return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			# Examine guard.
			if ExamineUI.is_open():
				_examine_pressed = true
				return

			# LMB just pressed. Start tracking hold duration.
			_examine_pressed = false
			_lmb_held = true
			_hold_timer = 0.0
			_radial_opened = false
		else:
			# Examine guard.
			if _examine_pressed:
				_examine_pressed = false
				_lmb_held = false
				return

			# LMB released.
			_lmb_held = false

			# Interaction menu.
			if _radial_opened:
				# LMB released while radial was open, execute highlighted option.
				var chosen = InteractionMenu.get_highlighted_interaction()
				if not chosen.is_empty() and hovered != null:
					hovered.execute_interaction(chosen["id"])
				InteractionMenu.close()
			elif hovered != null and _hold_timer < HOLD_THRESHOLD:
				# Fast click, execute default action directly.
				var interactions = hovered.get_interactions()
				if not interactions.is_empty():
					hovered.execute_interaction(interactions[0]["id"])

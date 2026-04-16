extends CanvasLayer

# VBoxContainer that contains our slot rows
@onready var slot_list = $PanelContainer/VBoxContainer

# Start hidden, then show once the [Inventory] keybind is pressed
var is_open = false

# Listen for inventory changes, redraw automatically if
# something is picked up, dropped, or changed
func _ready() -> void:
	visible = false
	GameState.inventory_changed.connect(_redraw)
	_redraw()

# Toggle inventory on keybind press
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("open_inventory"):
		is_open = !is_open
		visible = is_open
		# Redraw so it always shows the current state
		if is_open:
			_redraw()

# Redrawing of the visuals and stuff
func _redraw() -> void:
	# Clear existing rows
	for child in slot_list.get_children():
		child.queue_free()

	# Build one row per unlocked slot
	for slot_def in SlotRegistry.get_unlocked_slots():
		var slot_id = slot_def["id"]
		var contents = GameState.get_slot_contents(slot_id)
		
		var row = HBoxContainer.new()
		var slot_label = Label.new()
		var contents_label = Label.new()

		# Slot Name
		slot_label.text = slot_def["label"] + ":"
		slot_label.custom_minimum_size.x = 150

		# Slot Content
		if contents.is_empty():
			contents_label.text = "[ Empty ]"
		else:
			contents_label.text = ", ".join(contents)

		# Slot Itself
		row.add_child(slot_label)
		row.add_child(contents_label)
		slot_list.add_child(row)

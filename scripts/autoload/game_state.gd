extends Node

# LAYER STATE
# Which layer the cursor is currently "pointing at."
var cursor_layer = "midground"
# Emitted whenever the layer changes.
signal layer_changed(new_layer: String)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("cycle_layer"):
		cycle_layer()

# Change layer.
func cycle_layer() -> void:
	if cursor_layer == "midground":
		cursor_layer = "background"

	elif cursor_layer == "background":
		cursor_layer = "foreground"

	elif cursor_layer == "foreground":
		cursor_layer = "midground"
		
	layer_changed.emit(cursor_layer)

# INVENTORY STATE
# This dictionary maps slot IDs to arrays of item ID strings.
# An empty array means the slot is empty.
var inventory: Dictionary = {}
var unlocked_slots: Array = []
# Signal for whenever any slot's contents change
signal inventory_changed

# Builds the inventory dictionary from the definitions
func initialize_inventory(slot_definitions: Array) -> void:
	for slot in slot_definitions:
		inventory[slot["id"]] = []
		if slot["unlocked_by_default"]:
			unlocked_slots.append(slot["id"])

# Returns what's currently in a slot.
# Empty array = empty slot.
func get_slot_contents(slot_id: String) -> Array:
	if inventory.has(slot_id):
		return inventory[slot_id]
	
	return []

# Attempts to place an item into a slot
# True if successful, false if locked or full.
func place_item(slot_id: String, item_id: String) -> bool:
	# Locked status check
	if not slot_id in unlocked_slots:
		return false
	
	# Rudimentary hardcoded capacity check
	
	# --- TODO: FLAG VALIDATION!!!! ---
	var contents = inventory[slot_id]
	if contents.size() >= 1:
		return false

	# Add item
	contents.append(item_id)
	inventory_changed.emit()
	return true

func remove_item(slot_id: String, item_id: String) -> void:
	if inventory.has(slot_id):
		inventory[slot_id].erase(item_id)
		inventory_changed.emit()

extends Node

# Slot defs loaded from slots.json, keyed by slot ID for fast lookup.
var _slots: Dictionary = {}

# Once slots are loaded up, initialize GameState's inventory structure.
func _ready() -> void:
	_load_slots()
	GameState.initialize_inventory(_slots.values())

# Fill the slots Dictionary with ID definitions from the slots.json
func _load_slots() -> void:
	var file = FileAccess.open("res://assets/data/slots.json/", FileAccess.READ)

	# Error handling for safety's sake
	if not file:
		push_error("SlotRegistry: Could not open slots.json")
		return

	# Deserialize JSON
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	for slot_def in parsed:
		_slots[slot_def["id"]] = slot_def

func get_slot(slot_id: String) -> Dictionary:
	return _slots.get(slot_id, {})

func get_all_slots() -> Array:
	return _slots.values()

# Returns ONLY slot definitions that are currently unlocked
func get_unlocked_slots() -> Array:
	return (_slots.values().filter(func(s): return s["id"] in GameState.unlocked_slots))

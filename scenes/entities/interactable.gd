extends Area2D

@export var id: String = ""
@export_enum("background", "midground", "foreground") var layer: String = "background"
@export var has_examine = false
@export var has_pickup = false
@export var has_mechanism = false

# Track whether the mouse is physically over this object.
var _mouse_is_over: bool = false

func _ready() -> void:
	# Connect to on-hover signals.
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

	# Re-evaluate hover state whenever the layer cycles.
	GameState.layer_changed.connect(_on_layer_changed)

func _on_mouse_entered() -> void:
	_mouse_is_over = true
	_evaluate_hover()

func _on_mouse_exited() -> void:
	_mouse_is_over = false
	if InteractionSystem.hovered == self:
		InteractionSystem.clear_hovered()
		
# Re-evaluate so we register or deregister appropriately.
func _on_layer_changed(_new_layer: String) -> void:
	_evaluate_hover()

func _evaluate_hover() -> void:
	# Whether this object should be registered.
	if _mouse_is_over and layer == GameState.cursor_layer:
		InteractionSystem.set_hovered(self)
	else:
		# Either the mouse left, or the layer no longer matches.
		if InteractionSystem.hovered == self:
			InteractionSystem.clear_hovered()

# Returns all possible actions for this object.
func get_interactions() -> Array:
	var interactions: Array = []

	if has_examine == true:
		interactions.append({ "id": "examine", "label": "Examine" })
	
	if has_pickup == true:
		interactions.append({ "id": "pickup", "label": "Pick Up" })
	
	if has_mechanism == true:
		interactions.append({ "id": "mechanism", "label": "View Closer" })
	
	return interactions
	
func execute_interaction(interaction: String) -> void:
	if interaction == "examine":
		ExamineUI.show_for_id(id)

extends CanvasLayer

@onready var label: Label = $LayerLabel

func _ready() -> void:
	# Set initial text.
	_update_label(GameState.cursor_layer)
	
	# Connect to layer signal.
	GameState.layer_changed.connect(_update_label)

func _update_label(new_layer: String) -> void:
	label.text = "Layer: " + new_layer

extends CanvasLayer

# A temporary Label node that displays examine text.
# Will be replaced with the properly styled thought bubbles later.
var label = Label

func _ready() -> void:
	label = Label.new()
	label.name = "ExamineLabel"
	
	# Positioning it at the bottom center of the screen.
	label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size = Vector2(800, 100)
	
	add_child(label)
	label.visible = false

func show_text(text: String) -> void:
	label.text = text
	label.visible = true

func hide_text() -> void:
	label.visible = false

func _input(event: InputEvent) -> void:
	# Any interaction press dismisses the examine text.
	if event.is_action_pressed("ui_interact") and label.visible:
		hide_text()

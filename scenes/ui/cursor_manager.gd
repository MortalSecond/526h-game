extends CanvasLayer

# ICON ASSETS
const ICON_BG = preload("res://assets/icons/InteractionIconBG.png")
const ICON_BG_PLUS = preload("res://assets/icons/InteractionIconPlusBG.png")
const ICONS = {
	"examine": preload("res://assets/icons/examine.png"),
	"pickup": preload("res://assets/icons/pickup.png"),
	"mechanism": preload("res://assets/icons/mechanism.png"),
}
const CURSOR_EMPTY = preload("res://assets/icons/CursorEmpty.png")

const BG_SIZE        = Vector2(64, 64)
const ICON_SIZE      = Vector2(40, 40)
const ICON_OFFSET    = Vector2(12, 12)
# Subtracting half the circle size from the mouse position
# so the circle CENTER sits on the mouse, not its top-left corner.
const HOTSPOT_OFFSET = BG_SIZE / 2.0

# NODES
@onready var cursor_visual = $CursorVisual
@onready var bg_rect = $CursorVisual/BGRect
@onready var icon_rect = $CursorVisual/IconRect

# Hide the computer's mouse pointer thing, 
# replace it with our own.
func _ready() -> void:
	cursor_visual.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	bg_rect.texture = CURSOR_EMPTY
	icon_rect.visible = false

	# Set all sizes.
	cursor_visual.size = BG_SIZE
	bg_rect.size       = BG_SIZE
	bg_rect.position   = Vector2.ZERO
	icon_rect.size     = ICON_SIZE
	icon_rect.position = ICON_OFFSET

# Move the cursor visual to follow the actual mouse position.
func _process(_delta) -> void:
	cursor_visual.global_position = get_viewport().get_mouse_position()

# No interactable is hovered. Hide the composite icon.
func set_idle() -> void:
	bg_rect.texture = CURSOR_EMPTY
	icon_rect.visible = false

# An interactable is hovered. Show the appropriate composite.
func set_hover(interactions: Array) -> void:
	if interactions.is_empty():
		set_idle()
		return
	
	# Choose the correct background based on option count.
	# Single option = plain circle.
	# Multiple = circle with plus.
	if interactions.size() > 1:
		bg_rect.texture = ICON_BG_PLUS
	else:
		bg_rect.texture = ICON_BG
	
	# Show the primary (first) interaction's icon on top of the background.
	var primary_id = interactions[0]["id"]
	if ICONS.has(primary_id):
		icon_rect.texture = ICONS[primary_id]
		icon_rect.visible = true
	else:
		# Unknown icon, hide icon layer.
		icon_rect.visible = false

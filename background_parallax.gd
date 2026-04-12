extends Node2D

# These references use the @onready annotation, which means the node paths 
# will only be extracted once the scene is fully loaded. Trying to access
# $"../Midground/Player" before the scene is ready would return null.
@onready var player = $Midground/Player
@onready var background = $Background
@onready var foreground = $Foreground

# The horizontal center of this room in world coordinates.
# E.g. When Sam stands here, all layers are at offset zero. As he moves left or right,
# layers drift in the opposite direction by their respective amounts.
# Update this per-room to be half the room's pixel width.
@export var room_center_x: float = 640.0

# This multiplier controls how much each the layers drifts.
@export var bg_parallax_strength: float = 0.05
@export var fg_parallax_strength: float = 0.12

func _process(_delta):
	# If the player node doesn't exist yet (e.g. during editor preview),
	# bail out safely rather than crashing.
	if not player:
		return
	
	# How far Sam is from the room's center, in pixels.
	# Positive = Sam is right of center, negative = left of center.
	var offset = player.position.x - room_center_x
	
	# Move the entire Background node as one rigid unit.
	# The sub-layers inside it are unaffected by this.
	background.position.x = -offset * bg_parallax_strength
	foreground.position.x = -offset * fg_parallax_strength

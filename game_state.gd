extends Node

# Which layer the cursor is currently "pointing at."
var cursor_layer = "midground"

func cycle_layer():
	if cursor_layer == "midground":
		cursor_layer = "background"
	else:
		cursor_layer = "midground"

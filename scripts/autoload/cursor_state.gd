extends Node

enum Target   { IDLE, INTERACTABLE, MENU }
enum Activity { SETTLED, ENTERING, EXITING }

var target: Target = Target.IDLE
var activity: Activity = Activity.SETTLED

# The interactions of whatever is currently hovered.
# Empty when target is IDLE or MENU.
var current_interactions: Array = []

signal state_changed(new_target: Target, new_activity: Activity)

func set_target(new_target: Target, interactions: Array = []) -> void:
	# If the target isn't changing, there is nothing to do.
	# No signal, no animation.
	if new_target == target:
		return
	
	target = new_target
	current_interactions = interactions
	
	# Determine what kind of transition this is.
	# Anything moving toward IDLE is an exit. Anything moving away from IDLE is an enter.
	# Switching between two non-idle targets (e.g. INTERACTABLE to MENU) counts as entering.
	if new_target == Target.IDLE:
		activity = Activity.EXITING
	else:
		activity = Activity.ENTERING
	
	state_changed.emit(target, activity)

# Called by CursorManager once its animation finishes.
# Marks the cursor as having completed its transition.
func settle() -> void:
	activity = Activity.SETTLED
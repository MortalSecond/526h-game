extends CharacterBody2D

# Sam's walking speed.
@export var SPEED = 150.0

func _physics_process(_delta):
	# Movement input.
	var direction = Input.get_axis("ui_left", "ui_right")
	
	if direction:
		# Horizontal movement.
		velocity.x = direction * SPEED
	else:
		# Decelerate to zero when no input is held.
		# He stops in one frame rather than gliding until stopped.
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	move_and_slide()

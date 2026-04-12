extends CharacterBody2D

# SPEED controls how fast Sam walks horizontally.
# JUMP_VELOCITY is negative because in Godot's 2D coordinate system,
# Y increases DOWNWARD. So "up" is a negative Y value. Negative Y = up.
const SPEED = 200.0
const JUMP_VELOCITY = -400.0

func _physics_process(delta):
	# Apply gravity if Sam is NOT on the floor.
	if not is_on_floor():
		velocity.y += get_gravity().y * delta

	# Jump input.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Horizontal movement.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		# If no input, smoothly decelerate to zero.
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

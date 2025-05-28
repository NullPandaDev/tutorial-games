extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var game_over = false


func _physics_process(delta: float) -> void:
	if game_over:
		return 
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if Input.is_action_just_pressed("tap"):
		velocity.y = JUMP_VELOCITY

	move_and_slide()

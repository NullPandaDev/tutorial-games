extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 130.0
const JUMP_VELOCITY = -300.0
var health = 3.0
var alive = true


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if self.alive == false:
		velocity.x = 0
		direction = 0
		
	
	# Manage direction
	if direction != 0:
		sprite.flip_h = direction != 1
	
	# Manage sprite animation
	if is_on_floor():
		if direction == 0:
			sprite.animation = "idle"
		else:
			sprite.animation = "run" # or sprite.animation.play("run")?
	else:
		sprite.animation = "jump"


	move_and_slide()

func take_damage(damage):
	self.health -= damage
	if self.health <= 0.0:
		self.alive = false
		sprite.animation = "die"
	

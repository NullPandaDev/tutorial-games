extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hud_health_label = get_tree().get_first_node_in_group("HUD").get_node("Hearts/Label") as Label
@onready var hurt_sfx: AudioStreamPlayer2D = $Hurt
@onready var jump_sfx: AudioStreamPlayer2D = $Jump
@onready var die_sfx: AudioStreamPlayer2D = $Die

const SPEED = 130.0
const JUMP_VELOCITY = -250.0
const DOUBLE_JUMP_VELOCITY = -150.0
var health = 3.0
var alive = true
var double_jumped = false

func get_jump_velocity():
	if !self.alive:
		return 0.0
	if is_on_floor():
		return JUMP_VELOCITY
	
	if !is_on_floor():
		if self.double_jumped:
			return 0.0
		else:
			self.double_jumped = true
			return DOUBLE_JUMP_VELOCITY
	return 0.0

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		double_jumped = false
	
	# Handle jump.
	if Input.is_action_just_pressed("jump"):
		var jvelocity = get_jump_velocity()
		if jvelocity != 0.0:
			self.jump_sfx.play()
			velocity.y = jvelocity
	
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
	if self.alive:
		if is_on_floor():
			if direction == 0:
				sprite.animation = "idle"
			else:
				sprite.animation = "run" # or sprite.animation.play("run")?
		else:
			sprite.animation = "jump"
	else:
		sprite.animation = "die"
	#if is_on_floor():
		#if direction == 0:
			#sprite.animation = "idle"
		#else:
			#sprite.animation = "run" # or sprite.animation.play("run")?
	#else:
		#sprite.animation = "jump"
	#print(sprite.frame=="die")
	if sprite.animation == "die" && sprite.frame == 5:
		get_tree().reload_current_scene()

	move_and_slide()


#func _ready():
	#$AnimatedSprite2D.play("your_animation_name")
	#$AnimatedSprite2D.loop = false
	#$AnimatedSprite2D.connect("animation_finished", self, "_on_animation_finished")
#
#func _on_animation_finished():
	#print("Animation finished playing once.")

func take_damage(damage):
	if !self.alive:
		return
	
	self.hurt_sfx.play()
	self.health -= damage
	hud_health_label.text = "x" + str(int(self.health))
	print("Health: ", self.health)
	#sprite.animation = "damaged"
	
	if self.health <= 0.0:
		self.die_sfx.play()
		self.alive = false
		sprite.animation = "die"

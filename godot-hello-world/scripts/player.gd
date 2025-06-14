extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hud_health_label = get_tree().get_first_node_in_group("HUD").get_node("Hearts/Label") as Label
@onready var hurt_sfx: AudioStreamPlayer2D = $Hurt
@onready var jump_sfx: AudioStreamPlayer2D = $Jump
@onready var die_sfx: AudioStreamPlayer2D = $Die

const SPEED = 130.0
const JUMP_VELOCITY = -250.0
const DOUBLE_JUMP_VELOCITY = -150.0
const I_FRAMES = 24
@onready var original_modulate = sprite.modulate

var health = 3
var alive = true
var double_jumped = false
var iframes: int = 0
var current_flip_h = false
var paused = false
var movement_cooldown_frames = 0
var hurt = false

#class AnimationState:
	#var name: String
	#var value: int
	#
	#func _init(name: String = "", value: int = 0):
		#self.name = name
		#self.value = value

func is_rolling() -> bool:
	return sprite.animation == "roll" and sprite.frame < 5

func set_paused(value):
	self.paused = value

func get_jump_velocity():
	if !self.alive:
		return 0.0
	if is_on_floor():
		return JUMP_VELOCITY
	if is_on_wall():
		self.double_jumped = false
		return JUMP_VELOCITY*0.9
	
	if !is_on_floor():
		if self.double_jumped:
			return 0.0
		else:
			self.double_jumped = true
			return DOUBLE_JUMP_VELOCITY
	return 0.0

func calculate_gravity():
	if is_on_wall():
		if velocity.y > 0:
			return get_gravity()*0.1
		else:
			return get_gravity()
	else:
		return get_gravity()

func calc_speed():
	if is_rolling():
		return SPEED*1.75
	else:
		return SPEED
	

func _physics_process(delta: float) -> void:
	if self.paused:
		return

	self.iframes = max(0, self.iframes-1)
	self.movement_cooldown_frames = max(0, self.movement_cooldown_frames-1)
	if self.iframes > 0 and hurt:
		sprite.modulate = Color("red", float(self.iframes)/float(self.I_FRAMES)*2)
	else:
		sprite.modulate = self.original_modulate
		hurt = false

	# Add the gravity.
	if not is_on_floor():
		velocity += calculate_gravity() * delta
	else:
		double_jumped = false
	
	if self.movement_cooldown_frames > 0:
		return
	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and !is_rolling():
		var jvelocity = get_jump_velocity()
		if jvelocity != 0.0:
			self.jump_sfx.play()
			velocity.y = jvelocity
	
	if Input.is_action_just_pressed("roll") and is_on_floor():
		#sprite.animation = "roll"
		sprite.animation = "roll"
		self.iframes = 24 #(4/10)*60 4 frame animation / 10 fps * 60 fps physics process
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * calc_speed()
	else:
		velocity.x = move_toward(velocity.x, 0, calc_speed())
	
	if self.alive == false:
		velocity.x = 0
		direction = 0
		
	
	# Manage direction
	if direction != 0:
		sprite.flip_h = direction != 1
		self.current_flip_h = sprite.flip_h
	
	# Manage sprite animation
	if self.alive:
		if is_on_floor():
			if sprite.animation == "roll" and sprite.frame < 4:
				sprite.animation = "roll"
			else:
				if direction == 0:
					sprite.animation = "idle"
				else:
					sprite.animation = "run"
		else:
			if sprite.animation == "roll" and sprite.frame < 7:
				sprite.animation = "roll"
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

func take_damage(damage: int):
	if !self.alive or self.iframes > 0:
		# Don't take damage when dead or in iFrames
		return
	
	self.hurt = true
	self.hurt_sfx.play()
	self.health -= damage
	hud_health_label.text = "x" + str(self.health)
	#sprite.animation = "damaged"
	
	if self.health <= 0.0:
		self.die_sfx.play()
		self.alive = false
		sprite.animation = "die"
	self.iframes = self.I_FRAMES
	

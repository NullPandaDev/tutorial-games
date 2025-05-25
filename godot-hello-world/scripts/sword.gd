extends Node2D

@onready var attack_sfx: AudioStreamPlayer2D = $Sounds/AttackSFX
@onready var hurt_sfx: AudioStreamPlayer2D = $Sounds/HurtSFX
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

const REACH = 25
const DAMAGE = 1
const COOL_DOWN_FRAMES = 15

var in_attack = false
var direction = 0
var cooldown_frames = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.cooldown_frames = max(0, self.cooldown_frames-1)
	sprite.flip_v = self.get_parent().current_flip_h
	if sprite.flip_v:
		direction = -1
	else:
		direction = 1
	if Input.is_action_just_pressed("attack"):
		if !self.in_attack and self.cooldown_frames <= 0:
			self.sprite.animation = "attack"
			self.attack_sfx.play()
			self.in_attack = true
			self.direction = 1
	
	if self.in_attack:
		position.x += min(180*delta*direction, REACH)
		
		
		if (direction == 1 and position.x >= REACH) or (direction == -1 and position.x <= -REACH):
			self.sprite.animation = "idle"
			direction = 0
			position.x = 0
			self.in_attack = false
			self.cooldown_frames = self.COOL_DOWN_FRAMES

func _on_area_2d_area_entered(area: Area2D) -> void:
	# Just finds and kills slimes...
	if area is Area2D and area.name == "SlimeDZ" and self.in_attack:
		var slime = area.get_parent() as Node2D
		slime.take_damage(self.DAMAGE)
		hurt_sfx.play()
		

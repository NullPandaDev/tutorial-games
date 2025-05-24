extends Node2D

var SPEED = 30
var direction = 1
@onready var collision_shape_2d: CollisionShape2D = $Killzone/CollisionShape2D
@onready var left: RayCast2D = $Killzone/Left
@onready var right: RayCast2D = $Killzone/Right
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if left.is_colliding():
		sprite.flip_h = false
		direction = 1
	if right.is_colliding():
		sprite.flip_h = true
		direction = -1
	position.x += delta * SPEED * direction

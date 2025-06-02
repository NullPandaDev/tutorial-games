extends Node2D

@onready var root: Node2D = $"."
@onready var game = Game.new(root)

class Game:
	var ONE_EIGHT_DEG_IN_RAD = 3.14159
	var PROJECTILE_SCENE := preload("res://scenes/projectile.tscn")
	var root: Node2D
	var player: CharacterBody2D
	
	var shoot_time = 0.15
	var shoot_timer = 0.0
	
	
	func _init(root: Node2D) -> void:
		
		self.root = root
		self.player = root.get_node("Player")
	
	func _shoot():
		if player.get_direction() == 1:
			var marker = self.player.get_node("ProjectileMarkerRight")
			var projectile = PROJECTILE_SCENE.instantiate()
			projectile.direction = 1
			projectile.global_position = marker.global_position
			root.get_parent().add_child(projectile)
		else:
			var marker = self.player.get_node("ProjectileMarkerLeft")
			var projectile = PROJECTILE_SCENE.instantiate()
			projectile.direction = -1
			projectile.rotation = ONE_EIGHT_DEG_IN_RAD
			projectile.global_position = marker.global_position
			root.get_parent().add_child(projectile)
	
	func process(delta: float) -> void:
		if (Input.is_action_just_pressed("shoot") or Input.is_action_pressed("shoot")) and shoot_timer <= 0.0:
			self.shoot_timer = self.shoot_time
			_shoot()
		self.shoot_timer -= delta

func _process(delta: float) -> void:
	game.process(delta)

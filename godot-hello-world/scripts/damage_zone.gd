extends Area2D

@onready var timer: Timer = $Timer

@export var damage: float = 1.0

func _on_body_entered(body: Node2D) -> void:
	body.take_damage(self.damage)

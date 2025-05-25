extends Area2D

@onready var timer: Timer = $Timer

@export var damage: int = 1

func _on_body_entered(body: Node2D) -> void:
	print("did the job")
	body.take_damage(self.damage)

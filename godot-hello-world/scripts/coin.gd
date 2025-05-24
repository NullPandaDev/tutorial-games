extends Area2D

@onready var score_manager: Node = %ScoreManager

func _on_body_entered(body: Node2D) -> void:
	score_manager.add_point()
	queue_free()

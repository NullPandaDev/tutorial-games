extends Area2D

@onready var general_manager: Node = %GeneralManager

func _on_body_entered(body: Node2D) -> void:
	general_manager.add_point()
	queue_free()

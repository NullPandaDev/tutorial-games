extends Area2D

@onready var timer: Timer = $Timer # Added timer for tutorial value

func _on_body_entered(body: Node2D) -> void:
	var die_sfx = body.get_node("Die") as AudioStreamPlayer2D
	die_sfx.play()
	await get_tree().create_timer(die_sfx.stream.get_length()).timeout
	timer.start()

func _on_timer_timeout() -> void:
	get_tree().reload_current_scene()

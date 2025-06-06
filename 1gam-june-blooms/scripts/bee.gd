extends Area2D

signal bee_died

func _on_area_entered(area: Area2D) -> void:
	if (area.name == "Projectile"):
		area.queue_free()
	queue_free()
	emit_signal("bee_died")

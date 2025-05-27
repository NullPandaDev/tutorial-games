extends Control

signal resume_game

func _on_button_button_down() -> void:
	self.visible = false
	emit_signal("resume_game")


func _on_button_2_button_down() -> void:
	get_tree().quit()

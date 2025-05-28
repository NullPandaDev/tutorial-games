extends Node2D

signal plane_crash
signal spike_passed

#func _on_body_entered_spike_down(body: Node2D) -> void:
	#print("down")
	#emit_signal("plane_crash")
#
#
#func _on_body_entered_spike_up(body: Node2D) -> void:
	#print("up")
	#emit_signal("plane_crash")
#
#
#func _on_body_entered_spike_up(body: Node2D) -> void:
	#print("up")
	#emit_signal("plane_crash")
#
#
#func _on_body_entered_spike_down(body: Node2D) -> void:
	#print("down")
	#emit_signal("plane_crash")


func _on_up_body_entered_spike_up(body: Node2D) -> void:
	#print("up")
	emit_signal("plane_crash")


func _on_down_body_entered_spike_down(body: Node2D) -> void:
	#print("down")
	emit_signal("plane_crash")


func _on_spike_threshold_body_exited(body: Node2D) -> void:
	#print("passed spike")
	emit_signal("spike_passed")

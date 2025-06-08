extends Node2D

var direction: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$".".position.x += 200*delta*direction
	#print(position.x)


func _on_body_entered(body: Node2D) -> void:
	#var explode: CPUParticles2D = get_node("Explode").duplicate()
	#var end_pos = global_position
	#print(global_position)
	self.queue_free()
	#get_parent().add_child(explode)
	#print(explode.position)
	#explode.position = end_pos
	#explode.emitting = true
	#print(explode.position)

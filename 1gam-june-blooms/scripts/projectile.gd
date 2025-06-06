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
	self.queue_free()

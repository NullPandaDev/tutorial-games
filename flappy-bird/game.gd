extends Node2D


var speed = 600
var cooldown = 120
var game_over = false
var score = 0

@onready var SPIKE = get_tree().get_first_node_in_group("spike")

func move_spikes(delta: float):
	if game_over:
		return

	for spike in get_tree().get_nodes_in_group("spike"):
		spike.position.x -= delta * speed

func generate_spike(delta: float):
	if game_over:
		return
	
	self.cooldown = max(0, self.cooldown-1)
	if self.cooldown <= 0:
		var clone = SPIKE.duplicate()
		clone.position = SPIKE.position
		var camera = $Camera2D
		var viewport_width = get_viewport_rect().size.x
		var zoom = camera.zoom.x  # assuming uniform zoom
		var right_edge = camera.global_position.x + (viewport_width * 0.5 * zoom)
		clone.position.x = right_edge
		clone.position.y += randi_range(-50, 50)
		
		# Connect to spikes
		clone.connect("plane_crash", Callable(self, "_on_plane_crash_signal"))
		clone.connect("spike_passed", Callable(self, "_on_spike_passed_signal"))

		
		
		add_child(clone)
		self.cooldown = 150 + randi_range(0, 80)
		#$Spikes.add_child()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#print($Plane.position )
	generate_spike(delta)
	move_spikes(delta)


func _on_restart() -> void:
	get_tree().reload_current_scene()

func _on_plane_crash_signal() -> void:
	self.set_game_over()

func _on_spike_passed_signal():
	self.score += 1
	$HUD/ScoreLabel.text = str(self.score)

func set_game_over():
	#print("game over")
	self.game_over = true
	$Plane.game_over = true

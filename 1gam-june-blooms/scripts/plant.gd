class_name Plant extends Area2D

signal plant_grown

var frame_time = 1.0
var frame_timer = 0.0
var bees_on_flower = 0
const ANIMATIONS = ["RED", "YELLOW"]

func _ready() -> void:
	$AnimatedSprite2D.animation = ANIMATIONS[randi() % ANIMATIONS.size()]
	$AnimatedSprite2D.frame = 0

func _process(delta: float) -> void:
	frame_timer += delta
	if frame_timer >= frame_time and bees_on_flower > 0:
		$AnimatedSprite2D.frame += 1
		frame_timer = 0
		if $AnimatedSprite2D.frame == 9:
			remove_from_group("plant")
			emit_signal("plant_grown")
		#add_to_group("my_group")


func _on_area_entered(area: Area2D) -> void:
	if area.name.begins_with("Bee"):
		self.bees_on_flower += 1


func _on_area_exited(area: Area2D) -> void:
	if area.name.begins_with("Bee"):
		self.bees_on_flower -= 1


func _on_body_entered(body: Node2D) -> void:
	if !is_in_group("plant") and body.name.begins_with("Player"):
		body.player.power_up = $AnimatedSprite2D.animation
		body.player.amo = 10
		queue_free()

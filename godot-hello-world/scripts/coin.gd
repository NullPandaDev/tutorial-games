extends Area2D

#@onready var level_manager = %LevelManager
#@onready var level_manager = get_tree().get_root()

signal coin_collected

func _on_body_entered(body: Node2D) -> void:
	#print("Level Manager ", level_manager)
	#print("Level Manager ", level_manager, level_manager.name)
	#print("Level Manager ", level_manager, level_manager.get_general_manager())
	#return
	#self.level_manager.get_general_manager().add_point()
	print("coin_collected")
	emit_signal("coin_collected")
	queue_free()

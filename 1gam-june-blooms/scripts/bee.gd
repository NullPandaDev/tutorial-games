class_name Bee extends Area2D

const CURRENT_SCENE: PackedScene = preload("res://scenes/bee.tscn")
signal bee_died

var plants: Array[Plant]

static func create(plants: Array) -> Bee:
	var bee: Bee = CURRENT_SCENE.instantiate()
	for plant: Plant in plants:
		bee.plants.append(plant)
		bee.name = "Bee" + str(Engine.get_process_frames())
	return bee

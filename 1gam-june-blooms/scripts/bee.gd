class_name Bee extends Area2D

const CURRENT_SCENE: PackedScene = preload("res://scenes/bee.tscn")
signal bee_died

var path: PathFinder.Path
var path_finder: PathFinder
var plant: Plant
var plants: Array[Plant]

func _process(delta: float) -> void:
	#if !self.path:
		#self.path = self.path_finder.find_path(plants.get(0).position, position)
		#print("Path: ", self.path)
	
	if self.plant == null:
		if !plants.is_empty():
			self.plant = plants.get(0) # FIXME: Do some better algorithm maybe
			self.path = self.path_finder.find_path(self.plant.global_position, position) # FIXME: Never sure when to use posiion or global position :( 
			print(plants, ",", self.plant.global_position, ",", position)
			print("Path: ", self.path)
	elif self.path.is_path_active():
		position = self.path.get_next_position(position, 20*delta)

func append_plant(plant: Plant) -> void:
	self.plants.append(plant)


# Bee factory
static func create(path_finder: PathFinder, plants: Array) -> Bee:
	var bee: Bee = CURRENT_SCENE.instantiate()
	bee.path_finder = path_finder
	for plant: Plant in plants:
		bee.plants.append(plant)
		bee.name = "Bee" + str(Engine.get_process_frames())
	return bee

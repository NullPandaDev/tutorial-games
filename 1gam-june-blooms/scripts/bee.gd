class_name Bee extends Area2D

const CURRENT_SCENE: PackedScene = preload("res://scenes/bee.tscn")
signal bee_died

var path: PathFinder.Path
var path_finder: PathFinder
var plant: Plant
var plants: Array[Plant]

func get_closest_plant() -> Plant:
	return self.plants.get(randi() % self.plants.size())
	#var min_distance: float = 9999999999999
	#var result: Plant = null # FIXME: Pretty sure this breaks
	#for plant: Plant in self.plants:
		#var distance: float = (plant.position.y-position.y)**2 + (plant.position.x-position.x)**2
		#if distance < min_distance:
			#min_distance = distance
			#result = plant
	#return result

func get_unclaimed_plant() -> Plant:
	for plant: Plant in self.plants:
		if !plant.claimed:
			plant.claimed = true
			return plant
	return null

func _process(delta: float) -> void:
	#if !self.path:
		#self.path = self.path_finder.find_path(plants.get(0).position, position)
		#print("Path: ", self.path)
	
	if self.plant == null:
		if !plants.is_empty():
			#self.plant = get_closest_plant()
			self.plant = get_unclaimed_plant()
			if self.plant != null:
				#self.plant = plants.get(0) # FIXME: Do some better algorithm maybe
				self.path = self.path_finder.find_path(self.plant.global_position, position) # FIXME: Never sure when to use posiion or global position :( 
				#print(plants, ",", self.plant.global_position, ",", position)
				#print("Path: ", self.path)
	elif self.path.is_path_active():
		position = self.path.get_next_position(position, 20*delta)

func append_plant(plant: Plant) -> void:
	self.plants.append(plant)


# Bee factory
static func create(path_finder: PathFinder, plants: Array, i: int) -> Bee:
	var bee: Bee = CURRENT_SCENE.instantiate()
	bee.name = "Bee" + str(i)
	bee.path_finder = path_finder
	for plant: Plant in plants:
		bee.plants.append(plant)
	return bee


func _on_area_entered(area: Area2D) -> void:
	print(area.name)
	if area.name.begins_with("Projectile") or area.name.begins_with("EvilBee"):
		if area.name.begins_with("Projectile"):
			var explode: CPUParticles2D = area.get_node("ExplodeBee").duplicate()
			var end_pos = position
			get_parent().add_child(explode)
			explode.position = end_pos
			explode.emitting = true
			area.queue_free()
		queue_free()
		emit_signal("bee_died")

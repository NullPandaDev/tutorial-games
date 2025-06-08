extends Area2D

signal bee_died

var bee: Bee

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

#func refresh(tilemap: TileMap, plants: Array) -> void:
	#var area = Area2D.new()
	##area.position = #Vector2i(-12,-4)
	#self.bee = Bee.new(plants.get(0), $".", tilemap)
var plants: Array
var tilemap: TileMap
func refresh(tilemap: TileMap, plants: Array) -> void:
	self.plants = plants
	self.tilemap = tilemap
	var min_distance: float = 999999999.0
	var closest_plant = null
	for plant: Area2D in plants:
		var distance = abs(plant.position.x-$".".position.x) + abs(plant.position.y-$".".position.y)
		if distance < min_distance:
			min_distance = distance
			closest_plant = plant
	self.bee = Bee.new(closest_plant, $".", tilemap)


func _process(delta: float) -> void:
	self.bee.move_towards(delta)

class Bee:
	var astargrid: AStarGrid2D
	var path: Array[Vector2i]
	var plant: Area2D
	var evil_bee: Area2D
	var path_index: int
	
	func _init(plant: Area2D, evil_bee: Area2D, tilemap: TileMap) -> void:
		self.astargrid = AStarGrid2D.new()
		astargrid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
		self.evil_bee = evil_bee
		self.path_index = 0
		
		var region_start = Vector2i(-12, -7)
		var region_end = Vector2i(11, 6) # FIXME: Prettty sure that this should be less 1
		var region_size = region_end - region_start + Vector2i(1, 1) # Inclusive range

		astargrid.region = Rect2i(region_start, region_size)
		astargrid.cell_size = Vector2i(16, 16)
		astargrid.update()

		# Set all points as walkable (not solid)
		for x in range(region_start.x, region_end.x+1): # range(astargrid.region.position.x, astargrid.region.end.x+1)
			for y in range(region_start.y, region_end.y+1):
				astargrid.set_point_solid(Vector2i(x, y), false)
		astargrid.update()
		
		
		for x in range(region_start.x, region_end.x+1): # range(astargrid.region.position.x, astargrid.region.end.x+1)
			for y in range(region_start.y, region_end.y+1):
				var cell = Vector2i(x, y)
				var tile_id = tilemap.get_cell_source_id(0, cell)
				
				if tile_id != -1:
					var tile_data = tilemap.get_cell_tile_data(0, cell)
					var flyable = tile_data.get_custom_data("flyable")
					#print(flyable)
					#if !flyable:
						#print(cell, flyable)
					
					astargrid.set_point_solid(cell, !flyable)
		
		

		#var start: Vector2i = Vector2i(0,-6)
		#var end: Vector2i = Vector2i(-7,-6)
		if self.evil_bee != null and plant != null:
			var start: Vector2i = _world_to_map(self.evil_bee.position)
			var end: Vector2i = _world_to_map(plant.position)
			self.path = astargrid.get_id_path(start, end)
		else:
			self.path = []
		#print("Path:", path)
		#self.path = astargrid.get_id_path(start, Vector2i(-12, -4))
		

	func _map_to_world(cell: Vector2i) -> Vector2:
		var cell_size = astargrid.cell_size
		var x:float = cell.x*cell_size.x + cell_size.x/2
		var y:float = cell.y*cell_size.y + cell_size.y/2
		return Vector2(x, y)

	func _world_to_map(position: Vector2) -> Vector2i:
		var cell_size = astargrid.cell_size
		return Vector2i(floor(position.x / cell_size.x), floor(position.y / cell_size.y))

	func move_towards(delta:float):
		if self.path_index < self.path.size() and self.path[self.path_index] != null:
			var end = _map_to_world(self.path[path_index]) # FIXME: Adding in end pos and trying to keep straight line travel
			self.evil_bee.position = self.evil_bee.position.move_toward(Vector2(end.x, end.y), 20 * delta)
			if self.evil_bee.position == _map_to_world(self.path[path_index]):
				self.path_index += 1

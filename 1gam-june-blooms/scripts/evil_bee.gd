extends Area2D

var evil_bee: EvilBee
#var astargrid: AStarGrid2D

class EvilBee:
	var astargrid: AStarGrid2D
	var path: Array[Vector2i]
	var bee: Area2D
	var evil_bee: Area2D
	var path_index: int
	
	func _init(bee: Area2D, evil_bee: Area2D, tilemap: TileMap) -> void:
		self.bee = bee
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
		if self.evil_bee != null and bee != null:
			var start: Vector2i = _world_to_map(self.evil_bee.position)
			var end: Vector2i = _world_to_map(bee.position)
			self.path = astargrid.get_id_path(start, end)
		else:
			self.path = []
		#print("Path:", path)

	func _map_to_world(cell: Vector2i) -> Vector2:
		var cell_size = astargrid.cell_size
		var x:float = cell.x*cell_size.x + cell_size.x/2
		var y:float = cell.y*cell_size.y + cell_size.y/2
		return Vector2(x, y)

	func _world_to_map(position: Vector2) -> Vector2i:
		var cell_size = astargrid.cell_size
		return Vector2i(floor(position.x / cell_size.x), floor(position.y / cell_size.y))

	func has_bee_position_changed() -> bool:
		print(self.bee)
		if self.bee:
			print([self.bee.position, self.path[-1]])
			if _world_to_map(self.bee.position) != self.path[-1]:
				print("change pos!")
				return true
		return false

	func move_towards(delta:float):
		if self.path_index < self.path.size() and self.path[self.path_index] != null:
			var end = _map_to_world(self.path[path_index]) # FIXME: Adding in end pos and trying to keep straight line travel
			self.evil_bee.position = self.evil_bee.position.move_toward(Vector2(end.x, end.y), 15 * delta)
			if self.evil_bee.position == _map_to_world(self.path[path_index]):
				self.path_index += 1


func _on_area_entered(area: Area2D) -> void:
	if (area.name.begins_with("Projectile")):
		var explode: CPUParticles2D = area.get_node("ExplodeEvilBee").duplicate()
		var end_pos = position
		get_parent().add_child(explode)
		explode.position = end_pos
		explode.emitting = true
		
		
		area.queue_free()
		queue_free()
	#print(area, ",", area.name)

#func world_to_map(position: Vector2) -> Vector2i:
	#var cell_size = astargrid.cell_size
	#return Vector2i(floor(position.x / cell_size.x), floor(position.y / cell_size.y))

#func refresh(bees: Array, tilemap: TileMap) -> void:
	#print("refresh")
	#self.evil_bee = EvilBee.new(bees.get(0), $".", tilemap)
var bees: Array
var tilemap: TileMap
func refresh(bees: Array, tilemap: TileMap) -> void:
	self.bees = bees
	self.tilemap = tilemap
	var min_distance: float = 999999999.0
	var closest_bee = null
	for bee: Area2D in bees:
		var distance = abs(bee.position.x-$".".position.x) + abs(bee.position.y-$".".position.y)
		if distance < min_distance:
			min_distance = distance
			closest_bee = bee
	self.evil_bee = EvilBee.new(closest_bee, $".", tilemap)

var recalculate_time = 4.0
var recalculate_timer = 0.0

func _process(delta: float) -> void:
	recalculate_timer += delta
	if recalculate_timer >= recalculate_time:
		recalculate_timer = 0
		refresh(bees, tilemap)
	else:
		self.evil_bee.move_towards(delta)
		
		#
	#if self.evil_bee != null:
		#if self.evil_bee.has_bee_position_changed():
		#else:
			#self.evil_bee.move_towards(delta)

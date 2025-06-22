class_name PathFinder extends Node

var astargrid: AStarGrid2D
var current_position: Vector2
var destination: Vector2
var origin: Vector2
var path: Array[Vector2i]
var path_index: int
var tilemap: TileMap

func _init(tilemap: TileMap) -> void:
	self.astargrid = AStarGrid2D.new()
	astargrid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	self.current_position = origin
	self.path = []
	self.path_index = 0
	self.tilemap = tilemap
	
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
				
				astargrid.set_point_solid(cell, !flyable)
	
func find_path(destination: Vector2i, origin: Vector2i) -> Path:
	self.destination = destination
	self.origin = origin
	
	#var start: Vector2i = Vector2i(0,-6)
	#var end: Vector2i = Vector2i(-7,-6)
	var world_path: Array[Vector2] = []
	if self.origin != null and self.destination != null:
		var start: Vector2i = _world_to_map(self.origin)
		var end: Vector2i = _world_to_map(self.destination)
		self.path = astargrid.get_id_path(start, end)
		#print("Grid Path: ", self.path)
		for x: Vector2i in self.path:
			world_path.append(_map_to_world(x))
	return Path.new(world_path) # Likely don't store this

# Grid to position
func _map_to_world(cell: Vector2i) -> Vector2:
	var cell_size = astargrid.cell_size
	var x:float = cell.x*cell_size.x + cell_size.x/2
	var y:float = cell.y*cell_size.y + cell_size.y/2
	return Vector2(x, y)

func _world_to_map(position: Vector2) -> Vector2i:
	var cell_size = astargrid.cell_size
	return Vector2i(floor(position.x / cell_size.x), floor(position.y / cell_size.y))

func has_bee_position_changed() -> bool:
	if self.bee:
		if _world_to_map(self.bee.position) != self.path[-1]:
			return true
	return false

class Path:
	var index: int
	var path: Array[Vector2]
	
	func _init(path: Array[Vector2]) -> void:
		self.index = 0
		self.path = path
	
	func _to_string() -> String:
		return str(self.path)
	
	func __bool() -> bool:
		return self.path.is_empty()# FIXME: + or self.index >= self.path.size()?
	
	func is_path_active() -> bool:
		return !self.path.is_empty() and self.index < self.path.size()
	
	func get_next_position(current_position: Vector2, scaled_delta: float) -> Vector2:
		if is_path_active() and current_position == self.path.get(self.index):
			self.index += 1

		if !is_path_active():
			#print("[WARN] Should not ask for position if the path isn't active")
			return current_position

		return current_position.move_toward(self.path.get(self.index), scaled_delta)

extends Node2D

@onready var root: Node2D = $"."
@onready var game = Game.new(root, get_tree())
@onready var tilemap: TileMap = $TileMap

class Game:
	var ONE_EIGHT_DEG_IN_RAD = 3.14159
	var PROJECTILE_SCENE := preload("res://scenes/projectile.tscn")
	var root: Node2D
	var tree: SceneTree
	var player: CharacterBody2D
	
	var shoot_time = 0.15
	var shoot_timer = 0.0
	var power_ups: Object
	
	
	func _init(root: Node2D, tree: SceneTree) -> void:
		self.root = root
		self.tree = tree
		self.player = root.get_node("Player")
	
	func _shoot():
		if player.get_direction() == 1:
			var marker = self.player.get_node("ProjectileMarkerRight")
			var projectile = PROJECTILE_SCENE.instantiate()
			projectile.name = "Projectile" + str(Engine.get_process_frames())
			projectile.direction = 1
			projectile.global_position = marker.global_position
			root.get_parent().add_child(projectile)
			projectile.get_node("AnimatedSprite2D").animation = player.player.power_up
			
			#if player.player.power_up == "RED":
				#projectile.modulate =  Color(1, 0, 0)
			#elif player.player.power_up == "YELLOW":
				#projectile.modulate =  Color(252, 252, 0)
		else:
			var marker = self.player.get_node("ProjectileMarkerLeft")
			var projectile = PROJECTILE_SCENE.instantiate()
			projectile.get_node("AnimatedSprite2D").animation = player.player.power_up
			projectile.name = "Projectile" + str(Engine.get_process_frames())
			projectile.direction = -1
			projectile.rotation = ONE_EIGHT_DEG_IN_RAD
			projectile.global_position = marker.global_position
			root.get_parent().add_child(projectile)
			projectile.get_node("AnimatedSprite2D").animation = player.player.power_up
			
			#if player.player.power_up == "RED":
				#projectile.modulate =  Color(1, 0, 0)
			#elif player.player.power_up == "YELLOW":
				#projectile.modulate =  Color(252, 252, 0)

	func _get_closest_bee(evil_bee: Area2D, bees) -> Area2D:
		var closest_distance: float = 99999999
		var result: Area2D = null
		for bee: Area2D in bees:
			var current_distance: float = (bee.global_position.x-evil_bee.global_position.x)**2 + (bee.global_position.y-evil_bee.global_position.y)**2
			if (current_distance < closest_distance):
				closest_distance = current_distance
				result = bee
		return result

	func process(delta: float) -> void:
		if (Input.is_action_just_pressed("shoot") or Input.is_action_pressed("shoot")) and shoot_timer <= 0.0:
			self.shoot_timer = self.shoot_time
			_shoot()
		self.shoot_timer -= delta
		#_move_evil_bees(delta)


const evil_bee_spawn_time = 16.0
var evil_bee_spawn_timer = 0.0
var EVIL_BEE_SCENE := preload("res://scenes/evil_bee.tscn")
const evil_bee_spawn_cap = 8

func _process(delta: float) -> void:
	game.process(delta)
	
	evil_bee_spawn_timer += delta*(evil_bee_spawn_cap-get_tree().get_nodes_in_group("evil_bee").size())
	if evil_bee_spawn_timer >= evil_bee_spawn_time:
		print("SPAWN")
		evil_bee_spawn_timer = 0
		var spawns = get_tree().get_nodes_in_group("evil_bee_spawn")
		var spawn_pos = spawns[randi() % spawns.size()].position
		var eb = EVIL_BEE_SCENE.instantiate()
		get_parent().add_child(eb)
		eb.position = spawn_pos
		eb.refresh(get_tree().get_nodes_in_group("bee"), $TileMap)


var astargrid := AStarGrid2D.new()
func setup_grid():
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
			var tilemap: TileMap = $TileMap
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
	var start: Vector2i = world_to_map($EvilBees/EvilBee.position)
	var end: Vector2i = world_to_map($Bees/Bee2.position)
	var path := astargrid.get_id_path(start, end)
	print("Path:", path)
	#self.evil_bee = EvilBeeScript.EvilBee.new(path, $Bees/Bee2, $EvilBees/EvilBee, astargrid)
	self.evil_bee = $EvilBees/EvilBee.EvilBee.new(path, $Bees/Bee2, $EvilBees/EvilBee, astargrid)

func world_to_map(position: Vector2) -> Vector2i:
	var cell_size = astargrid.cell_size
	return Vector2i(floor(position.x / cell_size.x), floor(position.y / cell_size.y))

func _ready() -> void:
	var bees = get_tree().get_nodes_in_group("bee")
	for bee: Area2D in bees:
		bee.connect("bee_died", Callable(self, "_on_bee_died"))

	for evil_bee: Area2D in get_tree().get_nodes_in_group("evil_bee"):
		evil_bee.refresh(bees, $TileMap)
	
	var plants = get_tree().get_nodes_in_group("plant")
	for bee: Area2D in bees:
		bee.refresh($TileMap, plants)
	
	for plant: Area2D in plants:
		plant.connect("plant_grown", Callable(self, "_on_plant_grown"))

func _on_bee_died() -> void:
	await get_tree().process_frame # FIXME: This is a bit fucked

	print("recv 'bee_died'")
	var bees = get_tree().get_nodes_in_group("bee")
	print(bees)
	for evil_bee: Area2D in get_tree().get_nodes_in_group("evil_bee"):
		evil_bee.refresh(bees, $TileMap)

func _on_plant_grown() -> void:
	await get_tree().process_frame # FIXME: This is a bit fucked

	print("recv 'plant_grown'")
	var plants = get_tree().get_nodes_in_group("plant")
	for bee: Area2D in get_tree().get_nodes_in_group("bee"):
		bee.refresh($TileMap, plants)

const EvilBeeScript = preload("res://scripts/evil_bee.gd")
#class_name EvilBee
var evil_bee: EvilBeeScript.EvilBee

extends Node2D

@onready var root: Node2D = $"."
@onready var game = Game.new(root, get_tree())
@onready var tilemap: TileMap = $TileMap
@onready var bees: Array[Bee]

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
		print(self.player.player.amo)
		if self.player.player.amo <= 0:
			return

		self.player.player.amo -= 1
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


const EVIL_BEE_SPAWN_TIME = 16.0
var evil_bee_spawn_timer = 0.0
var EVIL_BEE_SCENE := preload("res://scenes/evil_bee.tscn")
var PLANT_SCENE := preload("res://scenes/plant.tscn")
const evil_bee_spawn_cap = 8

const PLANT_SPAWN_TIME = 1.0
var plant_spawn_timer = 0.0

func _process(delta: float) -> void:
	game.process(delta)
	
	evil_bee_spawn_timer += delta*(evil_bee_spawn_cap-get_tree().get_nodes_in_group("evil_bee").size())
	if evil_bee_spawn_timer >= EVIL_BEE_SPAWN_TIME:
		evil_bee_spawn_timer = 0
		var spawns = get_tree().get_nodes_in_group("evil_bee_spawn")
		var spawn: Marker2D = spawns[randi() % spawns.size()]
		if spawn.visible:
			var spawn_pos = spawn.position
			var eb = EVIL_BEE_SCENE.instantiate()
			get_parent().add_child(eb)
			eb.position = spawn_pos
			eb.refresh(get_tree().get_nodes_in_group("bee"), $TileMap)
	
	plant_spawn_timer += delta
	if plant_spawn_timer >= PLANT_SPAWN_TIME:
		var spawns = []
		for spawn in get_tree().get_nodes_in_group("plant_spawn"):
			if spawn.get_node("Plant") == null:
				spawns.append(spawn)
		var spawn: Area2D = spawns[randi() % spawns.size()] if spawns.size() > 0 else null
		if spawn != null and spawn.visible:
			var ps: Plant = PLANT_SCENE.instantiate()
			spawn.add_child(ps)
			plant_spawn_timer = 0.0
			#_on_plant_grown()
			print("SPAWNED PLANT")
			for bee: Bee in get_tree().get_nodes_in_group("bee"):
				bee.append_plant(ps)
			ps.connect("plant_grown", Callable(self, "_on_plant_grown"))
# Managed some good progress where we were able to put the pathfinder on the bee and abstract
# it away mostly
# Had good luck chasing an existing plant. But now we are trying to get future plants
# to update in the list of plants per bee. When a bee has no more plants to move towards
# it should move on. My code isn't quite working.
# There will probably be a bug with finding a plant then moving to the next
# Also should improve code to allow better plant picking

# Finally I would love to move this spawn code to the plant. THe check itself can be passed
# a delta and easliy know if it's time to spawn? Is that true? Probably not.
# THe spawn code can be moved as a factory mehtod

# Will be a degress of figuring out in the next session
			
		
func _ready() -> void:
	var path_finder: PathFinder = PathFinder.new($TileMap)
	
	for i in range(3):
		var new_bee = Bee.create(path_finder, [])
		new_bee.global_position = get_tree().get_nodes_in_group("bee_spawn").get(0).global_position
		add_child(new_bee)
		self.bees.append(new_bee)
	
	
	var bees = get_tree().get_nodes_in_group("bee")
	for bee: Area2D in bees:
		bee.connect("bee_died", Callable(self, "_on_bee_died"))

	for evil_bee: Area2D in get_tree().get_nodes_in_group("evil_bee"):
		evil_bee.refresh(bees, $TileMap)
	
	var plants: Array = get_tree().get_nodes_in_group("plant")
	#for bee: Area2D in bees: # FIXME 1
		#bee.refresh($TileMap, plants)
	
	for plant: Area2D in plants:
		plant.connect("plant_grown", Callable(self, "_on_plant_grown"))
	

	#path_finder.find_path(plants.get(0).position, new_bee.position)
	#assert(true, "FORCE FIAL. READ COMMENT")
	
# HERE: We will want to have path finder on the bee and have an abstracted method.
# But for now we will want to just work more on the pathfinder. Get it working.
# We got the path to work nicely. So it's just a matter of maybe changing the init to do just that and then
# Follow up call to gen path? With dest etc
# But honestly that's for later right now it seems like we will want to move it to the bee and then get the
# Bee moving to a single flower. THen to a set of flowers then get newly spawned flowers to attact the bee as well
	

func _on_bee_died() -> void:
	await get_tree().process_frame # FIXME: This is a bit fucked
	
	var bees = get_tree().get_nodes_in_group("bee")
	for evil_bee: Area2D in get_tree().get_nodes_in_group("evil_bee"):
		evil_bee.refresh(bees, $TileMap)

#func _on_plant_grown() -> void:
	#print("PLANT GROWN2")

func _on_plant_grown(plant: Plant) -> void:
	#print("PLANT GROWN1")
	await get_tree().process_frame # FIXME: This is a bit fucked
#
	var plants = get_tree().get_nodes_in_group("plant")
	
	for bee: Bee in get_tree().get_nodes_in_group("bee"):
		bee.plants = []
		for p: Plant in plants:
			bee.plants.append(p)
		if bee.plant == plant:
			bee.plant = null
	

const EvilBeeScript = preload("res://scripts/evil_bee.gd")
var evil_bee: EvilBeeScript.EvilBee

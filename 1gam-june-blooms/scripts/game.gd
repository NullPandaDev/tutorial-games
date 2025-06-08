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
		var spawn_pos = spawns[randi() % spawns.size()].position
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
		if spawn != null:
			var ps = PLANT_SCENE.instantiate()
			spawn.add_child(ps)
			plant_spawn_timer = 0.0
			_on_plant_grown()
			print("SPAWNED PLANT")
		
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
	
	var bees = get_tree().get_nodes_in_group("bee")
	for evil_bee: Area2D in get_tree().get_nodes_in_group("evil_bee"):
		evil_bee.refresh(bees, $TileMap)

func _on_plant_grown() -> void:
	await get_tree().process_frame # FIXME: This is a bit fucked

	var plants = get_tree().get_nodes_in_group("plant")
	for bee: Area2D in get_tree().get_nodes_in_group("bee"):
		bee.refresh($TileMap, plants)

const EvilBeeScript = preload("res://scripts/evil_bee.gd")
#class_name EvilBee
var evil_bee: EvilBeeScript.EvilBee

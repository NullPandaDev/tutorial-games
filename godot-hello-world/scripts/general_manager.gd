extends Node

#@onready var level: Node = %Level#.level_manager
var paused = false




#---------------------
# SCORE MANAGEMENT
#---------------------
@onready var pick_up_coin_sfx: AudioStreamPlayer2D = $Audio/PickUpCoin
@onready var hud_coin_label = get_tree().get_first_node_in_group("HUD").get_node("TextureRect/Label") as Label
@onready var level = %Level
@onready var game = self.get_tree().current_scene as Node2D
@onready var player = %Player
@onready var player_start = player.position

var score = 0
var level_number = 1
var game_over = false
const FINAL_LEVEL = "Level4"

func load_level():
	if level_number > 1:
		%Player.movement_cooldown_frames = 30

	self.paused = true
	var camera = %Camera as Camera2D
	camera.position_smoothing_enabled = false
	
	# Free the level
	if level:
		level.queue_free()
	await get_tree().process_frame  # Wait a frame to fully remove the old level
	
	# load the new level + add objective tracking
	level = load("res://scenes/Level" + str(self.level_number) + ".tscn").instantiate()
	level.name = "Level" + str(self.level_number)
	add_child(level)
	
	var objective_manager = level.get_node("%ObjectiveManager")
	objective_manager.connect("objectives_complete", Callable(self, "_on_objectives_complete"))
	
	# Set player position on the level
	%Player.position = level.get_node("%PlayerStart").position
	await get_tree().process_frame  # Wait a frame to fully remove the old level
	camera.position_smoothing_enabled = true
	connect_to_coins()
	connect_to_hazards()
	%Menu.connect("resume_game", Callable(self, "_on_menu_continue"))

	self.level_number += 1



func _on_objectives_complete():
	load_level()


func _ready():
	load_level()

func _on_menu_continue():
	resume_scenes()
		

func connect_to_coins():
	# Connect coin signals
	for coin in level.get_tree().get_nodes_in_group("coin"):
		coin.connect("coin_collected", Callable(self, "_on_coin_collected"))

func connect_to_hazards():
	for hazard in level.get_tree().get_nodes_in_group("hazard"):
		hazard.connect("player_death", Callable(self, "_on_player_death"))

func _on_player_death():
	#get_tree().reload_current_scene()
	$Player.take_damage(1)
	$Player.position = level.get_node("PlayerStart").position
	
	if $Player.health <= 0:
		get_tree().reload_current_scene()

func _on_coin_collected():
	pick_up_coin_sfx.play()
	score += 1
	hud_coin_label.text = "x" + str(score)


#---------------------
# MENU MANAGEMENT
#---------------------
# TODO: 1) Freeze game 2) Quite music 3) Grey out screen 4) Pause inputs, enemies and platforms
@onready var menu = %Menu as Control
#@onready var game = self.get_tree().current_scene as Node2D

func _process(delta: float) -> void:
	
	if Input.is_action_just_pressed("menu") and !game_over:
		menu.visible = !menu.visible
		if menu.visible:
			pause_scenes()
		else:
			resume_scenes()
	
	if level.name == FINAL_LEVEL:
		game_over = true
		%Player.paused = true
		
		var sprite = $Player.get_node("AnimatedSprite2D") as AnimatedSprite2D
		sprite.animation = "idle"
		sprite.modulate = player.original_modulate

func pause_scenes():
	%Player.paused = true
	var sprite = %Player.get_node("AnimatedSprite2D") as AnimatedSprite2D
	sprite.stop()
	
	for coin in level.get_tree().get_nodes_in_group("coin"):
		coin.get_node("AnimatedSprite2D").stop()
	
	for slime in level.get_tree().get_nodes_in_group("slime"):
		slime.get_node("AnimatedSprite2D").stop()
		slime.paused = true
		

func resume_scenes():
	%Player.paused = false
	var sprite = %Player.get_node("AnimatedSprite2D") as AnimatedSprite2D
	sprite.play()
	
	for coin in level.get_tree().get_nodes_in_group("coin"):
		coin.get_node("AnimatedSprite2D").play()
	
	for slime in level.get_tree().get_nodes_in_group("slime"):
		slime.get_node("AnimatedSprite2D").play()
		slime.paused = false

	

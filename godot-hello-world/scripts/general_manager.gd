extends Node

#@onready var level: Node = %Level#.level_manager
var paused = false

#func _ready() -> void:
	#print(level)
	#level.load_general_manager(self)


#---------------------
# SCORE MANAGEMENT
#---------------------
@onready var pick_up_coin_sfx: AudioStreamPlayer2D = $PickUpCoin
@onready var hud_coin_label = get_tree().get_first_node_in_group("HUD").get_node("TextureRect/Label") as Label
@onready var level = %Level
@onready var game = self.get_tree().current_scene as Node2D
@onready var player = %Player
@onready var player_start = player.position

var score = 0

func load_level2():
	if $Level:
		$Level.queue_free()

	await get_tree().process_frame  # Wait a frame to fully remove the old level

	var new_level = load("res://scenes/Level2.tscn").instantiate()
	add_child(new_level)
	player.position = player_start
	connect_to_coins()

func _ready():
	connect_to_coins()

func connect_to_coins():
	# Connect coin signals
	for coin in level.get_tree().get_nodes_in_group("coin"):
		coin.connect("coin_collected", Callable(self, "_on_coin_collected"))

func _on_coin_collected():
	pick_up_coin_sfx.play()
	score += 1
	hud_coin_label.text = "x" + str(score)
	
	if score == 2:
		load_level2()


#---------------------
# MENU MANAGEMENT
#---------------------
# TODO: 1) Freeze game 2) Quite music 3) Grey out screen 4) Pause inputs, enemies and platforms
@onready var menu = %Menu as Control
#@onready var game = self.get_tree().current_scene as Node2D

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("menu"):
		self.paused = true
		menu.visible = !menu.visible

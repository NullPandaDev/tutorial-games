extends Node

var paused = false

#---------------------
# SCORE MANAGEMENT
#---------------------
var score = 0

# I kind of cheated this. Tutorial wanted me to use animation but I refused
@onready var pick_up_coin_sfx: AudioStreamPlayer2D = $PickUpCoin

@onready var hud_coin_label = get_tree().get_first_node_in_group("HUD").get_node("TextureRect/Label") as Label

func add_point():
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
	if Input.is_action_just_pressed("menu"):
		self.paused = true
		menu.visible = !menu.visible

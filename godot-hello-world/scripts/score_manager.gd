extends Node

var score = 0

# I kind of cheated this. Tutorial wanted me to use animation but I refused
@onready var pick_up_coin_sfx: AudioStreamPlayer2D = $PickUpCoin

@onready var hud_coin_label = get_tree().get_first_node_in_group("HUD").get_node("TextureRect/Label") as Label

func add_point():
	pick_up_coin_sfx.play()
	score += 1
	hud_coin_label.text = "x" + str(score)

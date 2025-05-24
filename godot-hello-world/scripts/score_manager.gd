extends Node

var score = 0
@onready var score_lable: Label = $Score

# I kind of cheated this. Tutorial wanted me to use animation but I refused
@onready var pick_up_coin_sfx: AudioStreamPlayer2D = $PickUpCoin

func add_point():
	pick_up_coin_sfx.play()
	score += 1
	score_lable.text = "Score: " + str(score) # "Score: {}".format(score)
	#print("Score:", score)

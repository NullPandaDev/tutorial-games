class_name SoundPlayer extends Node

static func play_coin_sound():
	var SOUNDS_SCENE := preload("res://scenes/sounds.tscn")
	var sound: Node = SOUNDS_SCENE.instantiate()
	
	
	var coin_sfx: AudioStreamPlayer2D = sound.get_node("CoinSFX")
	coin_sfx.pitch_scale = randf_range(0.5,1.0)
	coin_sfx.play()

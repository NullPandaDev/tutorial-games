extends Node

signal objectives_complete

func _ready() -> void:
	#await get_tree().process_frame  # Wait a frame to fully remove the old level
	#await get_tree().process_frame # Wait a frame to fully remove the old level
	#
	#if get_parent().name == "Level1" or get_parent().name == "Level2":
		#emit_signal("objectives_complete")
		
	connect_to_coins()

func connect_to_coins():
	# Connect coin signals
	for coin in get_tree().get_nodes_in_group("coin"):
		coin.connect("coin_collected", Callable(self, "_on_coin_collected"))
	
	for slime in get_tree().get_nodes_in_group("slime"):
		slime.connect("slime_killed", Callable(self, "_on_slime_killed"))

func _on_coin_collected():
	await get_tree().process_frame  # Wait a frame to fully remove the old level
	if get_parent().name == "Level1" or get_parent().name == "Level3":
		if get_tree().get_nodes_in_group("coin").size() == 0:
			emit_signal("objectives_complete")
	#elif get_parent().name == "Level2":
		#if get_tree().get_nodes_in_group("coin").size() == 2:
			#emit_signal("objectives_complete")

func _on_slime_killed():
	await get_tree().process_frame  # Wait a frame to fully remove the old level
	if get_parent().name == "Level2":
		if get_tree().get_nodes_in_group("slime").size() == 0:
			emit_signal("objectives_complete")

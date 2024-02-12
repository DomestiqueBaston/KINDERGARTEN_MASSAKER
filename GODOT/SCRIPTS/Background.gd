extends StaticBody2D

func get_alien_starting_point():
	var which = randi() % 5
	return get_node("Alien_Starting_Points/Point_%d" % (which + 1)).position

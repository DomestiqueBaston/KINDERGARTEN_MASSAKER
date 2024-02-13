extends StaticBody2D

#
# Returns the background's bounding box (a Rect2).
#
func get_limits():
	var size = $Sprite.texture.get_size()
	return Rect2($Sprite.position - size / 2, size)

#
# Returns one of the predefined starting points for the alien, chosen at random (a Vector2).
#
func get_alien_starting_point():
	var which = randi() % 5
	return get_node("Alien_Starting_Points/Point_%d" % (which + 1)).position

extends StaticBody2D

const START_POINT_COUNT = 5
const SPAWN_POINT_COUNT = 19

#
# Returns the background's bounding box (a Rect2).
#
func get_limits():
	var size = $Sprite.texture.get_size()
	return Rect2($Sprite.position - size / 2, size)

#
# Returns one of the predefined starting points for the alien, chosen at random
# (a Vector2).
#
func get_alien_starting_point():
	var index = randi() % START_POINT_COUNT
	return get_node("Alien_Starting_Points/Point_%d" % (index + 1)).position

#
# Returns one of the predefined starting points for the teacher or a kid,
# chosen at random (a Vector2).
#
func get_spawning_point():
	var index = randi() % SPAWN_POINT_COUNT
	return get_node("Kids_Spawning_Points/Point_%02d" % (index + 1)).position

#
# Returns one or more unique, predefined starting points for the teacher or
# kids, chosen at random (an array of Vector2).
#
func get_spawning_points(count):
	assert(count <= SPAWN_POINT_COUNT)
	var indices = []
	for _i in range(count):
		var index = randi() % SPAWN_POINT_COUNT
		while indices.has(index):
			index = randi() % SPAWN_POINT_COUNT
		indices.append(index)
	var positions = []
	for index in indices:
		positions.append(
			get_node("Kids_Spawning_Points/Point_%02d" % (index + 1)).position)
	return positions

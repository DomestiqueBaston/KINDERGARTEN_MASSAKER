extends StaticBody2D

const START_POINT_COUNT = 5
const SPAWN_POINT_COUNT = 86

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

func _get_spawning_position(index):
	return get_node("Kids_Spawning_Points/Point_%02d" % (index + 1)).position

#
# Returns one of the predefined starting points for the teacher or a kid, chosen
# at random (a Vector2). If include_rect is given, only points inside that Rect2
# are taken into consideration; if exclude_rect is given, only points outside
# that Rect2 are taken into consideration.
#
func get_spawning_point(include_rect=null, exclude_rect=null):
	while true:
		var pos = _get_spawning_position(randi() % SPAWN_POINT_COUNT)
		if include_rect and not include_rect.has_point(pos):
			continue
		if exclude_rect and exclude_rect.has_point(pos):
			continue
		return pos

#
# Returns one or more unique, predefined starting points for the teacher or
# kids, chosen at random (an array of Vector2). If include_rect is given, only
# points inside that Rect2 are taken into consideration; if exclude_rect is
# given, only points outside that Rect2 are taken into consideration.
#
# NB. This function will go into an infinite loop if you give it rectangles that
# are so restrictive that there are not enough spawning points that satisfy the
# constraints. And if there are just barely enough points to be found, the
# function may take a long time to find them; it is not at all efficient in that
# case.
#
func get_spawning_points(count, include_rect=null, exclude_rect=null):
	assert(count <= SPAWN_POINT_COUNT)
	var positions = []
	var indices = []

	for _i in range(count):
		while true:
			var index = randi() % SPAWN_POINT_COUNT
			if indices.has(index):
				continue
			var pos = _get_spawning_position(index)
			if include_rect and not include_rect.has_point(pos):
				continue
			if exclude_rect and exclude_rect.has_point(pos):
				continue
			indices.append(index)
			positions.append(pos)
			break

	return positions

#
# Creates an instance of the given scene, adds it as a child of the background,
# and places it at the given position. Returns the new instance.
#
func instance_character_at(scene, pos):
	var inst = scene.instance()
	inst.position = pos
	$YSort.add_child(inst)
	return inst

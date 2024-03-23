extends Node

# sprite animations are at 10 frames per second
const FPS = 10

#
# alien talents
#
enum Talent {
	TELEPORT,
	DASH,
	EXPLOSION,
	FREEZE,
	SPEED,
	FORCE_FIELD,
	TIME_STOP,
	MIRROR_IMAGE,
	DODGE,
	INVISIBLE,
	SHIELD,
	SECOND_LIFE,
	HEALTH,
	REGENERATE,
	HAND_TO_HAND,
	RANGED_COMBAT,
	NONE,
	TECHNICIAN,
	RANDOM,
	VOMIT_PROOF,
	BULLET_TIME,
	GHOST
}

#
# talent names
#
const talent_name = [
	"random teleportation",
	"dash",
	"repulsive explosion",
	"freezing shockwave",
	"quick runner",
	"force field",
	"time stop",
	"mirror images",
	"dodger",
	"invisible",
	"shield",
	"second life",
	"healthy",
	"regeneration",
	"hand to hand specialist",
	"ranged fighting expert",
	"none!",
	"der Techniker",
	"Zufällig",
	"Kotzsicher",
	"bullet time",
	"ghost"
]

#
# "weapons" (anything that causes damage to the alien)
#
enum Weapon {
	NONE,
	STICK,
	KICK,
	BOOGER,
	SPIT,
	VOMIT
}

func _ready():
	assert(Talent.size() == talent_name.size())
	randomize()

#
# Returns a random direction vector (NOT normalized) that can be fed to an
# AnimationNodeBlendSpace2D.
#
func get_random_direction() -> Vector2:
	match randi() % 8:
		0:
			return Vector2(0, 1)
		1:
			return Vector2(-1, 1)
		2:
			return Vector2(-1, 0)
		3:
			return Vector2(-1, -1)
		4:
			return Vector2(0, -1)
		5:
			return Vector2(1, -1)
		6:
			return Vector2(1, 0)
		_:
			return Vector2(1, 1)

#
# Given any direction vector (normalized or not), returns the "cardinal"
# direction (one of eight, NOT normalized) that is nearest to that one and can
# be fed to an AnimationNodeBlendSpace2D.
#
func get_nearest_direction(dir: Vector2) -> Vector2:
	var vec = dir.normalized()
	var angle = atan2(-vec.x, -vec.y)			# in the range [-PI, PI]
	var deg = int(stepify(rad2deg(angle), 45))	# -180, -135, -90, -45, 0, etc.
	if deg <= -180:
		return Vector2(0, 1)
	elif deg <= -135:
		return Vector2(1, 1)
	elif deg <= -90:
		return Vector2(1, 0)
	elif deg <= -45:
		return Vector2(1, -1)
	elif deg <= 0:
		return Vector2(0, -1)
	elif deg <= 45:
		return Vector2(-1, -1)
	elif deg <= 90:
		return Vector2(-1, 0)
	else:
		return Vector2(-1, 1)

#
# Returns the square of the distance between two points, adjusting for the
# game's weird perspective: neighboring pixels are considered to be farther
# away from each other in Y than in X.
#
func get_persp_dist_squared(p1: Vector2, p2: Vector2) -> float:
	var dx = p2.x - p1.x
	var dy = (p2.y - p1.y) * 1.5
	return dx*dx + dy*dy

#
# Returns a velocity vector to go from one point to another at a given speed,
# but adjusting the speed to the game's weird perspective: characters and
# projectiles can move faster in X than in Y.
#
func get_persp_velocity(from: Vector2, to: Vector2, speed: float) -> Vector2:
	var vec = from.direction_to(to)
	var dx = vec.x
	var dy = vec.y * 0.667
	return vec * (speed * sqrt(dx*dx + dy*dy))

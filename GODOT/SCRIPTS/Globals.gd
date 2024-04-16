extends Node

# sprite animations are at 10 frames per second
const FPS = 10

# true => allow messages to console
const VERBOSE = false

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
	RANDOM,
	VOMIT_PROOF,
	BULLET_TIME,
	GHOST,
	TECHNICIAN
}

class TalentDef:
	var talent_name: String
	var required_score: float
	
	func _init(name: String, score: float = -1):
		talent_name = name
		required_score = score

	func is_enabled(dialogue_seen: bool, best_score: float) -> bool:
		return (required_score < 0 or
				(dialogue_seen and required_score <= best_score))

var talents = []

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
	talents.resize(Talent.size())
	talents[Talent.TELEPORT] = TalentDef.new("random teleportation")
	talents[Talent.DASH] = TalentDef.new("dash")
	talents[Talent.EXPLOSION] = TalentDef.new("repulsive explosion")
	talents[Talent.FREEZE] = TalentDef.new("freezing shockwave")
	talents[Talent.SPEED] = TalentDef.new("quick runner")
	talents[Talent.FORCE_FIELD] = TalentDef.new("force field")
	talents[Talent.TIME_STOP] = TalentDef.new("time stop")
	talents[Talent.MIRROR_IMAGE] = TalentDef.new("mirror images")
	talents[Talent.DODGE] = TalentDef.new("dodger")
	talents[Talent.INVISIBLE] = TalentDef.new("invisible")
	talents[Talent.SHIELD] = TalentDef.new("shield")
	talents[Talent.SECOND_LIFE] = TalentDef.new("second life")
	talents[Talent.HEALTH] = TalentDef.new("healthy")
	talents[Talent.REGENERATE] = TalentDef.new("regeneration")
	talents[Talent.HAND_TO_HAND] = TalentDef.new("hand to hand specialist")
	talents[Talent.RANGED_COMBAT] = TalentDef.new("ranged fighting expert")
	talents[Talent.NONE] = TalentDef.new("none!")
	talents[Talent.RANDOM] = TalentDef.new("Zufällig", 0)
	talents[Talent.VOMIT_PROOF] = TalentDef.new("Kotzsicher", 20)
	talents[Talent.BULLET_TIME] = TalentDef.new("bullet time", 35)
	talents[Talent.GHOST] = TalentDef.new("ghost", 50)
	talents[Talent.TECHNICIAN] = TalentDef.new("der Techniker", 63)
	randomize()

#
# Returns a human-readable, English name for the given talent.
#
func get_talent_name(talent: int) -> String:
	return talents[talent].talent_name

#
# Returns true if the given talent is enabled, false if it is locked, either
# because it requires the user to watch the dialogue first, or because it
# requires a higher best score.
#
func is_talent_enabled(
	talent: int, dialogue_seen: bool, best_score: float) -> bool:
	return talents[talent].is_enabled(dialogue_seen, best_score)

#
# Returns a talent at random. Call this when the user has chosen the RANDOM
# talent and you want an actual, usable talent. Locked talents (depending on
# the user's best score) are ignored. It is assumed that the user has seen the
# dialogue, otherwise the RANDOM talent would not be unlocked.
#
func get_random_talent(best_score: float) -> int:
	var candidates = []
	for talent in Talent.size():
		if (talent != Talent.RANDOM
			and talents[talent].is_enabled(true, best_score)):
			candidates.append(talent)
	return candidates[randi() % candidates.size()]

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
# Returns a velocity vector to go from one point toward another at a given
# speed, but adjusting the speed to the game's weird perspective: characters
# and projectiles can move faster in X than in Y.
#
func get_persp_velocity(from: Vector2, to: Vector2, speed: float) -> Vector2:
	var vec = from.direction_to(to)
	var dx = vec.x
	var dy = vec.y * 0.667
	return vec * (speed * sqrt(dx*dx + dy*dy))

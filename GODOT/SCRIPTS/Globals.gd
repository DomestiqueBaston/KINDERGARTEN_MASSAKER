extends Node

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
# talent cooldown times
#
const talent_cooldown = [
	10,
	15,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	0
]

func _ready():
	assert(Talent.size() == talent_name.size())
	assert(Talent.size() == talent_cooldown.size())
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

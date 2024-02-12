extends Node

#
# Alien talents
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
	"der techniker",
	"zufällig",
	"kotzsicher",
	"bullet time",
	"ghost"
]

func _ready():
	assert(Talent.size() == talent_name.size())
	randomize()

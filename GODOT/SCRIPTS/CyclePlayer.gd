extends Node

class_name CyclePlayer

#
# The "cardinal" directions a character may face.
#
enum Dir {
	S,
	SW,
	W,
	NW,
	N,
	NE,
	E,
	SE
}

#
# The prefix in animation cycle names corresponding to each of the "cardinal"
# directions. That is, if for a cycle called "Idle", the AnimationPlayer must
# actually contain eight animations: "00_Idle", "45D_Idle", etc.
#
const prefix = [
	"00",	# Dir.S
	"45D",	# Dir.SW
	"90D",	# Dir.W
	"135D",	# Dir.NW
	"180",	# Dir.N
	"135G",	# Dir.NE
	"90G",	# Dir.E
	"45G"	# Dir.SE
]

#
# Record of a single call to play(), containing the name of the animation cycle
# and whether subsequent calls should block until the end of the cycle.
#
class AnimRequest:
	var name: String
	var block := false

# path to the scene's AnimationPlayer node
export var anim_player_path: NodePath

# the AnimationPlayer node
var anim_player: AnimationPlayer

# direction the character is facing
var current_direction = Dir.S

# the current animation (an AnimRequest), the next queued animation, and so on
var anim_queue: Array

func _ready():
	anim_player = get_node(anim_player_path)
	anim_player.connect("animation_changed", self, "_on_animation_changed")

#
# Plays the given animation cycle. The given name must NOT include the
# direction, so e.g. pass "Idle" and not "90G_Idle".
#
# If block is true, then subsequent calls to play() will block until the cycle
# has finished playing; otherwise, subsequent calls will transition immediately
# from this cycle to the new one.
#
# So if the current animation is blocking, the new animation is queued to play
# when the current and any other queued animations finish; otherwise, the new
# animation plays immediately, starting at the same position in time as the
# current animation.
#
func play(anim: String, block := false):

	# turn looping on for the new animation

	var full_name = _full_anim_name(anim)
	anim_player.get_animation(full_name).set_loop(true)

	# if the last animation requested is blocking, turn looping off for it, so
	# that it will eventually transition to the new animation; if it is not
	# blocking, the new animation will replace it

	if anim_queue.size() > 0:
		var last_req: AnimRequest = anim_queue.back()
		if last_req.block:
			_set_anim_loop(last_req.name, false)
		else:
			anim_queue.pop_back()

	# if one or more animations must finish before the new one begins, just
	# queue it up; otherwise, start the new animation playing immediately in
	# place of the current animation, at the same position

	if anim_queue.size() > 0:
		anim_player.queue(full_name)
	elif anim_player.is_playing():
		var t = anim_player.current_animation_position
		anim_player.play(full_name)
		anim_player.seek(t)
	else:
		anim_player.play(full_name)

	# push the new animation request onto the queue to keep track of it

	var request = AnimRequest.new()
	request.name = anim
	request.block = block
	anim_queue.push_back(request)

#
# Stops the current animation and clears the animation queue.
#
func stop():
	anim_player.stop()
	anim_player.clear_queue()
	anim_queue.clear()

#
# Returns the name of the animation cycle currently playing, or an empty string
# if there is none. Note that the returned string does NOT contain the prefix
# indicating the direction, e.g. it returns "Idle" and not "90G_Idle".
#
func get_current_animation() -> String:
	if anim_queue.empty():
		return ""
	else:
		return anim_queue.front().name

func _full_anim_name(anim: String) -> String:
	return "%s_%s" % [ prefix[current_direction], anim ]

func _set_anim_loop(anim: String, loop: bool):
	anim_player.get_animation(_full_anim_name(anim)).set_loop(loop)

#
# Specifies the direction the character is facing as a Vector2. The vector need
# not be normalized. CyclePlayer will actually use the "cardinal" direction that
# is nearest to the given vector (see Dir). The current animation and any queued
# animations are adjusted accordingly.
#
func set_direction_vector(dirvec: Vector2):
	var vecnrm = dirvec.normalized()
	var angle = atan2(-vecnrm.x, -vecnrm.y)		# in the range [-PI, PI]
	var deg = int(stepify(rad2deg(angle), 45))	# -180, -135, -90, -45, 0, etc.
	var dir
	if deg <= -180:
		dir = Dir.S
	elif deg <= -135:
		dir = Dir.SE
	elif deg <= -90:
		dir = Dir.E
	elif deg <= -45:
		dir = Dir.NE
	elif deg <= 0:
		dir = Dir.N
	elif deg <= 45:
		dir = Dir.NW
	elif deg <= 90:
		dir = Dir.W
	else:
		dir = Dir.SW
	set_direction(dir)

#
# Specifies the direction the character is facing as one of the eight "cardinal"
# directions (see Dir). The current animation and any queued animations are
# adjusted accordingly.
#
func set_direction(dir: int):
	if current_direction == dir:
		return

	current_direction = dir

	anim_player.clear_queue()
	if not anim_player.is_playing():
		return

	var full_name = _full_anim_name(anim_queue.front().name)
	var t = anim_player.current_animation_position
	anim_player.get_animation(full_name).set_loop(anim_queue.size() == 1)
	anim_player.play(full_name)
	anim_player.seek(t)

	for i in range(1, anim_queue.size()):
		full_name = _full_anim_name(anim_queue[i].name)
		anim_player.get_animation(full_name).set_loop(
			i == anim_queue.size() - 1)
		anim_player.queue(full_name)

#
# Sets the speed of playback for all animations: 1 for normal speed, larger
# values for higher speeds, smaller values for lower speeds, and negative values
# to play animations backwards.
#
func set_speed(speed: float):
	anim_player.playback_speed = speed

#
# Method invoked whenever a queued animation replaces the current animation.
# This allows us to keep our animation queue in sync with the AnimationPlayer's,
# popping the current animation off the front of the queue.
#
func _on_animation_changed(_old_name, _new_name):
	anim_queue.pop_front()
	assert(anim_queue.size() == anim_player.get_queue().size() + 1)

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
	for anim in anim_player.get_animation_list():
		anim_player.get_animation(anim).loop = false
	anim_player.connect("animation_changed", self, "_on_animation_changed")
	anim_player.connect("animation_finished", self, "_on_animation_finished")

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

	if anim_queue.size() > 0:
		var req = anim_queue.front()
		if req.name == anim and req.block == block:
			return

	# if the last animation requested is not blocking, the new animation will
	# replace it

	if anim_queue.size() > 0 and not anim_queue.back().block:
		anim_queue.pop_back()

	# if one or more animations must finish before the new one begins, just
	# queue it up; otherwise, start the new animation playing immediately in
	# place of the current animation, at the same position

	var full_name = _full_anim_name(anim)

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

func _full_anim_name(anim: String) -> String:
	return "%s_%s" % [ prefix[current_direction], anim ]

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

	if anim_queue.size() > 0:
		var full_name = _full_anim_name(anim_queue.front().name)
		var t = anim_player.current_animation_position
		anim_player.play(full_name)
		anim_player.seek(t)

	for i in range(1, anim_queue.size()):
		var full_name = _full_anim_name(anim_queue[i].name)
		anim_player.queue(full_name)

#
# Sets the speed of playback for all animations: 1 for normal speed, larger
# values for higher speeds, smaller values for lower speeds, and negative values
# to play animations backwards.
#
func set_speed(speed: float):
	anim_player.playback_speed = speed

#
# When the AnimationPlayer starts a queued animation, pop the corresponding
# animation off the front of our queue.
#
func _on_animation_changed(_old_name, _new_name):
	anim_queue.pop_front()

#
# When the AnimationPlayer finishes the requested animation, tell it to loop.
#
func _on_animation_finished(anim_name):
	anim_player.play(anim_name)

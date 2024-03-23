tool
extends KinematicBody2D
class_name Runner

# Class used by any creature that runs (aliens, children or teachers) to play
# the sounds of footsteps. It uses an Area2D to detect vomit puddles on the
# ground and to make the sounds dry or wet, as appropriate. And it exposes a
# property "step_hack" that can be triggered from an AnimationPlayer, even in
# the Godot editor (hence the "tool" keyword at the start of the script).

# audio stream: right step on dry ground
export var dry_step_1: AudioStream

# audio stream: left step on dry ground
export var dry_step_2: AudioStream

# audio stream: right step on wet ground
export var wet_step_1: AudioStream

# audio stream: left step on wet ground
export var wet_step_2: AudioStream

# Area2D for detecting vomit on the ground
export var vomit_detector_path: NodePath

# AudioStreamPlayer that plays the footsteps
export var audio_stream_player_path: NodePath

# AnimationPlayer that triggers the footsteps
export var animation_player_path: NodePath

#
# This fake property can be animated by an AnimationPlayer Property track,
# rather than having a Call Method track call play_step(). The advantage of the
# property is that Call Method tracks are not executed in the Godot editor,
# whereas property tracks are, IF you include the "tool" keyword at the top of
# the script...
#
var step_hack := false setget set_step_hack, get_step_hack

var _vomit_detector: Area2D
var _audio_player: Node
var _anim_player: AnimationPlayer
var _is_connected := false
var _puddle_count := 0

func _ready():
	if not Engine.editor_hint:
		_vomit_detector = get_node(vomit_detector_path)
	_audio_player = get_node(audio_stream_player_path)
	_anim_player = get_node(animation_player_path)

#
# Connects the vomit detector to start detecting puddles, if it has not already
# been done.
#
func start_checking_for_puddles():
	if not _is_connected:
		_puddle_count = 0
		_vomit_detector.connect("body_entered", self, "_on_vomit_entered")
		_vomit_detector.connect("body_exited", self, "_on_vomit_exited")
		_is_connected = true

#
# Disconnects the vomit detector and resets the puddle count.
#
func stop_checking_for_puddles():
	if _is_connected:
		_vomit_detector.disconnect("body_entered", self, "_on_vomit_entered")
		_vomit_detector.disconnect("body_exited", self, "_on_vomit_exited")
		_puddle_count = 0
		_is_connected = false

#
# Plays the sound of the left or right footstep. If one or more puddles have
# been detected at the current location, the wet sound is played.
#
func play_step(left: bool):
	if _puddle_count > 0:
		_audio_player.stream = wet_step_2 if left else wet_step_1
	else:
		_audio_player.stream = dry_step_2 if left else dry_step_1
	_audio_player.play()

#
# Accessor for the "step_hack" property: calls play_step().
#
func set_step_hack(left: bool):
	if _anim_player:
		play_step(left)
	step_hack = left

func get_step_hack() -> bool:
	return step_hack

func _on_vomit_entered(_body: Node):
	if _puddle_count == 0:
		vomit_entered()
	_puddle_count += 1

func _on_vomit_exited(_body: Node):
	_puddle_count -= 1
	if _puddle_count == 0:
		vomit_exited()

#
# Method invoked when the character steps into a puddle of vomit. The default
# implementation does nothing.
#
func vomit_entered():
	pass

#
# Method invoked when the character is no longer in a puddle of vomit. The
# default implementation does nothing.
#
func vomit_exited():
	pass

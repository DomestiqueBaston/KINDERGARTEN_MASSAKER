tool
extends Enemy

# length in seconds of her Check (default) animation
var idle_length: float

# length in seconds of her OMG animation
var OMG_length: float

# length in seconds of her No animation
var no_length: float

func init_timer():
	idle_length = $AnimationPlayer.get_animation("00_Check").length
	OMG_length = $AnimationPlayer.get_animation("00_OMG").length
	no_length = $AnimationPlayer.get_animation("00_No").length
	_start_checking()

func on_timer_timeout():
	if $AnimationPlayer.current_animation.ends_with("_Run"):
		_start_checking()
	else:
		_start_running()

#
# Plays the Check animation cycle 2-4 times.
#
func _start_checking():
	$CyclePlayer.play("Check")
	start_timer(idle_length * (2 + randi() % 3))

#
# Plays the Run animation cycle 2-4 seconds plus any extra_wait time.
#
func _start_running(extra_wait := 0.0):
	$CyclePlayer.play("Run")
	start_timer(extra_wait + rand_range(2, 4))

#
# Called by _physics_process().
#
func tick(delta):
	if $CyclePlayer.is_paused():
		return

	# can't see the alien => run at random like any other character

	if not is_alien_visible():
		.tick(delta)

	# run towards the alien and stop to yell at him when close enough

	elif $AnimationPlayer.current_animation.ends_with("_Run"):
		face_alien()
		if is_alien_in_range():
			$CyclePlayer.play("No", true)
			_start_running(no_length)
		else:
			.tick(delta)

	# No or OMG => turn to face alien without moving

	elif not $AnimationPlayer.current_animation.ends_with("_Check"):
		face_alien()

#
# Don't try to get around the alien; just stop when he is reached.
#
func want_to_avoid_collider(collider: Object) -> bool:
	return collider.name != "ALIEN"

#
# If the alien becomes visible while in the Check animation cycle, play the
# OMG animation, then start running toward him.
#
func alien_seen():
	if $AnimationPlayer.current_animation.ends_with("_Check"):
		$CyclePlayer.play("OMG", true)
		_start_running(OMG_length)

#
# If the alien leaves the teacher's field of vision while she is yelling at
# him, interrupt the No animation and start running again.
#
func alien_gone():
	if $AnimationPlayer.current_animation.ends_with("_No"):
		$CyclePlayer.stop()
		# This test prevents a warning message when the # "body_exited" signal
		# is triggered at the end of the game, when the Enemy parent class has
		# exited the tree but the subclass has not yet...
		if not is_being_deleted():
			_start_running()

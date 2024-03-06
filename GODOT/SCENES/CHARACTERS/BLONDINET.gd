extends Enemy

# length in seconds of the Slash animation
onready var slash_length = $AnimationPlayer.get_animation("00_Slash").length

func on_timer_timeout():
	if $AnimationPlayer.current_animation.ends_with("_Run"):
		$CyclePlayer.play(default_anim)
		start_timer(rand_range(2, 5))
	else:
		_start_running()

#
# Plays the Run animation cycle 2-5 seconds plus any extra_wait time.
#
func _start_running(extra_wait := 0.0):
	$CyclePlayer.play("Run")
	start_timer(extra_wait + rand_range(2, 5))

#
# Stops attacking (at the end of the Slash animation cycle) and starts running
# again.
#
func _stop_slashing():
	var extra_wait := 0.0
	if $AnimationPlayer.current_animation.ends_with("_Slash"):
		extra_wait = slash_length - $AnimationPlayer.current_animation_position
	_start_running(extra_wait)

#
# Called by _physics_process().
#
func tick(delta):
	if Engine.editor_hint or $CyclePlayer.is_paused():
		return

	# can't see the alien => run at random like any other character

	if not is_alien_visible():
		if $AnimationPlayer.current_animation.ends_with("_Slash"):
			_stop_slashing()
		.tick(delta)

	# run towards the alien and stop to attack him when close enough

	elif $AnimationPlayer.current_animation.ends_with("_Run"):
		face_alien()
		if is_alien_in_range():
			$CyclePlayer.play("Slash", true)
		else:
			.tick(delta)

	# while attacking, keep turned towards the alien

	elif $AnimationPlayer.current_animation.ends_with("_Slash"):
		face_alien()

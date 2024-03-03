extends Enemy

# length in seconds of the Kick animation
onready var kick_length = $AnimationPlayer.get_animation("00_Kick").length

func on_timer_timeout():
	if is_running:
		$CyclePlayer.play(default_anim)
		timer.start(rand_range(2, 4) / $CyclePlayer.get_speed())
		is_running = false
	else:
		_start_running()

#
# Plays the Run animation cycle 2-5 seconds plus any extra_wait time.
#
func _start_running(extra_wait := 0.0):
	$CyclePlayer.play("Run")
	timer.start(extra_wait + rand_range(2, 5) / $CyclePlayer.get_speed())
	is_running = true

#
# Called by _physics_process().
#
func tick(delta):
	if Engine.editor_hint or $CyclePlayer.get_speed() == 0:
		return

	# can't see the alien => run at random like any other character

	if not is_alien_visible():
		.tick(delta)

	# run towards the alien and stop to kick him when close enough

	elif $AnimationPlayer.current_animation.ends_with("_Run"):
		face_alien()
		var dist2 = (alien.position - position).length_squared()
		if dist2 < attack_distance * attack_distance:
			print("kicking...")
			$CyclePlayer.play("Kick", true)
			_start_running(kick_length)
		else:
			.tick(delta)

func _on_successful_kick(_area: Area2D):
	print("kicked!")

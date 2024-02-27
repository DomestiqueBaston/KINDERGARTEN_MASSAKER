extends Enemy

onready var vomit_length = $AnimationPlayer.get_animation("00_Vomit").length

func on_timer_timeout():

	# running => either vomit or idle 1-3 seconds

	if is_running:

		# vomit until end of cycle then run

		if randf() < 0.33:
			$CyclePlayer.play("Vomit", true)
			timer.start(vomit_length * 0.5 / $CyclePlayer.get_speed())

		# idle 1-3 seconds

		else:
			$CyclePlayer.play(default_anim)
			timer.start((1 + 2 * randf()) / $CyclePlayer.get_speed())

	# not running => start running for 2-5 seconds

	else:
		$CyclePlayer.play(run_anim)
		var time_to_wait = 2 + 3 * randf()

		# We set the timer above to go off during the Vomit cycle, to ensure
		# that play("Run") is called before the cycle ends. The transition to
		# Run won't happen until the end of the Vomit cycle, so we have to add
		# to the timer however much time is remaining in the cycle.

		if "Vomit" in $AnimationPlayer.current_animation:
			time_to_wait += (
				vomit_length - $AnimationPlayer.current_animation_position)

		timer.start(time_to_wait / $CyclePlayer.get_speed())

	is_running = not is_running

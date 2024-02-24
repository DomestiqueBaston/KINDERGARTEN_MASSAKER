extends Enemy

var vomit_blend_param := "parameters/Vomit/BlendSpace2D/blend_position"
onready var vomit_length = $AnimationPlayer.get_animation("00_Vomit").length

func _on_timer_timeout():

	# running => either vomit or idle 1-3 seconds

	if is_running:
		$AnimationTree[idle_blend_param] = $AnimationTree[run_blend_param]
		$AnimationTree[vomit_blend_param] = $AnimationTree[run_blend_param]

		# vomit until end of cycle (transition out of Vomit is AtEnd)

		if randf() < 0.5:
			state_machine.travel("Vomit")
			timer.start(vomit_length * 0.5)

		# idle 1-3 seconds

		else:
			state_machine.travel(default_anim)
			timer.start(1 + 2 * randf())

	# not running => start running for 2-5 seconds

	else:
		$AnimationTree[run_blend_param] = $AnimationTree[idle_blend_param]
		state_machine.travel(run_anim)
		var time_to_wait = 2 + 3 * randf()
		if state_machine.get_current_node() == "Vomit":
			time_to_wait += (state_machine.get_current_length() -
							 state_machine.get_current_play_position())
		timer.start(time_to_wait)

	is_running = not is_running

extends Enemy

# length in seconds of her Check (default) animation
var idle_length: float

func init_timer():
	idle_length = $AnimationPlayer.get_animation("00_Check").length
	timer.start(idle_length * (2 + randi() % 3))
	
func on_timer_timeout():

	# running => stop and do 2-4 Check cycles

	if is_running:
		$AnimationTree[idle_blend_param] = $AnimationTree[run_blend_param]
		state_machine.travel(default_anim)
		is_running = false
		timer.start(idle_length * (2 + randi() % 3))

	# not running => start running for 2-4 seconds

	else:
		$AnimationTree[run_blend_param] = $AnimationTree[idle_blend_param]
		state_machine.travel(run_anim)
		is_running = true
		timer.start(rand_range(2, 4))

extends Enemy

# length in seconds of her Check (default) animation
var idle_length: float

func init_timer():
	idle_length = $AnimationPlayer.get_animation("00_Check").length
	timer.start(idle_length * (2 + randi() % 3) / $CyclePlayer.get_speed())

func on_timer_timeout():

	# running => stop and do 2-4 Check cycles

	if is_running:
		$CyclePlayer.play(default_anim)
		timer.start(idle_length * (2 + randi() % 3) / $CyclePlayer.get_speed())

	# not running => start running for 2-4 seconds

	else:
		$CyclePlayer.play(run_anim)
		timer.start(rand_range(2, 4) / $CyclePlayer.get_speed())

	is_running = not is_running

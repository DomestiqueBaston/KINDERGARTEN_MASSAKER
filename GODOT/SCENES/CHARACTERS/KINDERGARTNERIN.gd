extends Enemy

# length in seconds of her Check (default) animation
var idle_length

func _init_movement():
	var dir = Globals.get_random_direction()
	direction = dir.normalized()
	$AnimationTree[idle_blend_param] = dir
	state_machine.travel(default_anim)
	is_running = false
	idle_length = $AnimationPlayer.get_animation("00_Check").length
	timer.start(idle_length * (2 + randi() % 3))

func _on_timer_timeout():
	if is_running:
		$AnimationTree[idle_blend_param] = $AnimationTree[run_blend_param]
		state_machine.travel(default_anim)
		timer.start(idle_length * (2 + randi() % 3))
	else:
		$AnimationTree[run_blend_param] = $AnimationTree[idle_blend_param]
		state_machine.travel(run_anim)
		timer.start(rand_range(2, 4))
	is_running = not is_running

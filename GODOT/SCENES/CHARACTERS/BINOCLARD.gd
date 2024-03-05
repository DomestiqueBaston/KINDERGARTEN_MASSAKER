extends Enemy

# length in seconds of the Kick animation
onready var kick_length = $AnimationPlayer.get_animation("00_Kick").length

var kick_allowed := true
var kick_count: int

func on_timer_timeout():
	if $AnimationPlayer.current_animation.ends_with("_Run"):
		$CyclePlayer.play(default_anim)
		timer.start(rand_range(2, 4) / $CyclePlayer.get_speed())
	else:
		_start_running()

#
# Plays the Run animation cycle 2-5 seconds plus any extra_wait time.
#
func _start_running(extra_wait := 0.0):
	$CyclePlayer.play("Run")
	timer.start(extra_wait + rand_range(2, 5) / $CyclePlayer.get_speed())

#
# Stops kicking (at the end of the Kick animation cycle), turns around and
# runs in the opposite direction.
#
func _stop_kicking():
	var extra_wait := 0.0
	if $AnimationPlayer.current_animation.ends_with("_Kick"):
		extra_wait = kick_length - $AnimationPlayer.current_animation_position
	_start_running(extra_wait)
	kick_allowed = false
	$Kick_Timer.start()

#
# Called by _physics_process().
#
func tick(delta):
	if Engine.editor_hint or $CyclePlayer.is_paused():
		return

	# can't see the alien => run at random like any other character

	if not is_alien_visible():
		if $AnimationPlayer.current_animation.ends_with("_Kick"):
			_stop_kicking()
		.tick(delta)

	# run towards the alien and stop to kick him when close enough

	elif $AnimationPlayer.current_animation.ends_with("_Run"):
		var kick_him = false
		if kick_allowed:
			face_alien()
			var dist2 = (alien.position - position).length_squared()
			if dist2 < attack_distance * attack_distance:
				kick_him = true
		if kick_him:
			kick_count = 0
			$CyclePlayer.play("Kick", true)
		else:
			.tick(delta)

	# stop kicking after three successful kicks

	elif $AnimationPlayer.current_animation.ends_with("_Kick"):
		face_alien()
		if kick_count >= 3:
			_stop_kicking()

func _on_successful_kick(_area: Area2D):
	kick_count += 1

func _on_Kick_Timer_timeout():
	kick_allowed = true

func _on_animation_changed(old_name: String, new_name: String):
	if old_name.ends_with("_Kick") and new_name.ends_with("_Run"):
		turn_around()

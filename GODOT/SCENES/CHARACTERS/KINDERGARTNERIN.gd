tool
extends Enemy

# distance from alien where teacher starts yelling at him
export var close_enough_to_alien := 100.0

# length in seconds of her Check (default) animation
var idle_length: float

# length in seconds of her OMG animation
var OMG_length: float

# the alien, if he can be seen
var alien: Node2D

func init_timer():
	idle_length = $AnimationPlayer.get_animation("00_Check").length
	OMG_length = $AnimationPlayer.get_animation("00_OMG").length
	_start_checking()

func on_timer_timeout():
	if is_running:
		_start_checking()
	else:
		_start_running()

#
# Plays the Check animation cycle 2-4 times.
#
func _start_checking():
	$CyclePlayer.play("Check")
	timer.start(idle_length * (2 + randi() % 3) / $CyclePlayer.get_speed())
	is_running = false

#
# Plays the Run animation cycle 2-4 seconds plus any extra_wait time.
#
func _start_running(extra_wait := 0.0):
	$CyclePlayer.play("Run")
	timer.start(extra_wait + rand_range(2, 4) / $CyclePlayer.get_speed())
	is_running = true

#
# Turns the teacher to face the alien.
#
func _face_alien():
	if alien:
		var dir = alien.position - position
		dir = Globals.get_nearest_direction(dir)
		direction = dir.normalized()
		$CyclePlayer.set_direction_vector(direction)

#
# Called by _physics_process().
#
func tick(delta):
	if Engine.editor_hint or $CyclePlayer.get_speed() == 0:
		return

	# can't see the alien => run at random like any other character

	if alien == null:
		.tick(delta)

	# run towards the alien and stop to yell at him when close enough

	elif $AnimationPlayer.current_animation.ends_with("_Run"):
		_face_alien()
		var dist2 = (alien.position - position).length_squared()
		if dist2 < close_enough_to_alien * close_enough_to_alien:
			$CyclePlayer.play("No")
			# continue until the No animation finishes or is interrupted
			timer.stop()
		else:
			.tick(delta)

	# No or OMG => turn to face alien without moving

	elif not $AnimationPlayer.current_animation.ends_with("_Check"):
		_face_alien()

#
# If the alien becomes visible while in the Check animation cycle, play the
# OMG animation, then start running toward him.
#
func _on_Alien_Detection_Collider_body_entered(body: Node):
	alien = body
	if $AnimationPlayer.current_animation.ends_with("_Check"):
		$CyclePlayer.play("OMG", true)
		_start_running(OMG_length)

#
# If the alien leaves the teacher's field of vision while she is yelling at
# him, stop the No animation and start running again.
#
func _on_Alien_Detection_Collider_body_exited(_body: Node):
	if not $Alien_Detection_Collider/ADCollider.disabled:
		alien = null
		if $AnimationPlayer.current_animation.ends_with("_No"):
			_start_running()

#
# If the No animation finishes, start running again.
#
func _on_AnimationPlayer_animation_finished(anim_name: String):
	if anim_name.ends_with("_No"):
		_start_running()

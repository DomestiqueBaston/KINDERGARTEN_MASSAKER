extends Node2D

# signal emitted when bullet time is over (but not when stop() is called)
signal done

var running := false

#
# Starts bullet time, which will last for the given amount of time in seconds.
#
func start(duration: float):
	$AnimationPlayer.play("bullet_time_on")
	var anim_off = $AnimationPlayer.get_animation("bullet_time_off")
	$Bullet_Timer.start(max(0, duration - anim_off.length))
	running = true

#
# Interrupts bullet time, if it is running. Does nothing otherwise.
#
func stop():
	$AnimationPlayer.play("RESET")
	$Bullet_Timer.stop()
	running = false

#
# Returns true if bullet time is running.
#
func is_running() -> bool:
	return running

func _on_Bullet_Timer_timeout():
	$AnimationPlayer.play("bullet_time_off")

func _on_animation_finished(anim_name):
	if anim_name == "bullet_time_off":
		running = false
		emit_signal("done")

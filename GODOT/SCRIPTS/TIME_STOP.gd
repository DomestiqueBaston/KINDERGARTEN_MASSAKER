extends Node2D

# signal emitted when time stop is over (but not when stop() is called)
signal done

var running := false

#
# Stops time for the given amount of time in seconds.
#
func start(duration: float):
	$AnimationPlayer.play("time_stop")
	var anim_off = $AnimationPlayer.get_animation("time_restart")
	$Time_Stop_Timer.start(max(0, duration - anim_off.length))
	running = true

#
# Restarts time, if it has been stopped. Does nothing otherwise.
#
func stop():
	$AnimationPlayer.stop()
	$Time_Stop_Timer.stop()
	running = false

#
# Returns true if time is stopped.
#
func is_running() -> bool:
	return running

func _on_Time_Stop_Timer_timeout():
	$AnimationPlayer.play("time_restart")

func _on_animation_finished(anim_name):
	if anim_name == "time_restart":
		running = false
		emit_signal("done")

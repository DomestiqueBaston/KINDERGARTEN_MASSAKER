extends Node

# signal emitted when the ghost effect wears off (not when stop() is called)
signal done

var running := false

#
# Starts the ghost effect (animation and sound). The duration of the effect is
# determined by the length of the sound sample and cannot be modified.
#
func start():
	# the effect wears off when the sound FX end
	var off_anim_duration = $AnimationPlayer.get_animation("ghost_off").length
	$Ghost_Timer.start($FX.stream.get_length() - off_anim_duration)
	$FX.play()
	$AnimationPlayer.play("ghost_on")
	running = true

func _on_Ghost_Timer_timeout():
	$FX.stop()
	$AnimationPlayer.play("ghost_off")

func _on_animation_finished(anim_name):
	if anim_name == "ghost_off":
		emit_signal("done")
		running = false

#
# Interrupts the ghost effect in progress.
#
func stop():
	$Ghost_Timer.stop()
	$FX.stop()
	$AnimationPlayer.play("RESET")
	running = false

#
# Returns true if the ghost effect is on.
#
func is_running() -> bool:
	return running

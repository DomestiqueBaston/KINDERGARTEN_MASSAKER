extends Node2D

func start(duration):
	$AnimationPlayer.play("time_stop")
	$Time_Stop_Timer.start(
		duration - $AnimationPlayer.get_animation("time_restart").length)
	yield($Time_Stop_Timer, "timeout")
	$AnimationPlayer.play("time_restart")

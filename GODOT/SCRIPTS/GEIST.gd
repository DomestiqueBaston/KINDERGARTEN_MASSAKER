extends Node2D

func start(duration):
	$FX.play()
	$AnimationPlayer.play("ghost_on")
	$Ghost_Timer.start(duration)

func _on_Ghost_Timer_timeout():
	$FX.stop()
	$AnimationPlayer.play("RESET")

func stop():
	$Ghost_Timer.stop()
	$FX.stop()
	$AnimationPlayer.play("ghost_off")

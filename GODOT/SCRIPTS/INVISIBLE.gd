extends Node2D

func start(duration):
	var off_anim = $AnimationPlayer.get_animation("invisible_off")
	$Invisible_Timer.start(duration - off_anim.length)
	$AnimationPlayer.play("invisible_on")

func _on_Invisible_Timer_timeout():
	$AnimationPlayer.play("invisible_off")

func stop():
	$Invisible_Timer.stop()
	$AnimationPlayer.play("RESET")

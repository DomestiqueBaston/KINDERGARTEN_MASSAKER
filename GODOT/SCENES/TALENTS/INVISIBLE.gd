extends Node2D

func start(duration):
	var off_anim = $AnimationPlayer.get_animation("invisible_off")
	$Invisible_Timer.start(duration - off_anim.length)
	$AnimationPlayer.play("invisible_on")
	yield($Invisible_Timer, "timeout")
	$AnimationPlayer.play("invisible_off")

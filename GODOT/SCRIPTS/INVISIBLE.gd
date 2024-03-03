extends Node2D

signal done

func start(duration):
	var off_anim = $AnimationPlayer.get_animation("invisible_off")
	$Invisible_Timer.start(duration - off_anim.length)
	$AnimationPlayer.play("invisible_on")

func _on_Invisible_Timer_timeout():
	$AnimationPlayer.play("invisible_off")
	emit_signal("done")

func stop():
	$Invisible_Timer.stop()
	$AnimationPlayer.play("RESET")

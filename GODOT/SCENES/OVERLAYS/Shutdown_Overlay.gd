extends CanvasLayer

func start_animation():
	$AnimationPlayer.play("Screen_Shut_Down")

func reset_animation():
	$AnimationPlayer.play("RESET")

extends CanvasLayer

func start_animation():
	$AnimationPlayer.play("animation")

func reset_animation():
	$AnimationPlayer.play("RESET")

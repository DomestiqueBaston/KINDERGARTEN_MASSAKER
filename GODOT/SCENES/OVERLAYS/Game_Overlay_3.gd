extends CanvasLayer

func start_animation():
	$AnimationPlayer.play("animation")

func rewind_animation():
	$AnimationPlayer.seek(0)

func reset_animation():
	$AnimationPlayer.play("RESET")

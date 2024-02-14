extends CanvasLayer

signal animation_started

func start_animation():
	$AnimationPlayer.play("Screen_Shut_Down")

func reset_animation():
	$AnimationPlayer.play("RESET")

func _on_AnimationPlayer_animation_started(_anim_name):
	emit_signal("animation_started")

extends CanvasLayer

signal transition_finished

func start_transition():
	$Sprite.take_screenshot()

func _on_AnimationPlayer_animation_finished(_anim_name):
	emit_signal("transition_finished")

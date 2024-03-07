extends Node2D

# signal emitted when the explosion hits something
signal hit

# signal emitted when the explosion's animation has finished
signal done

func set_time_scale(scale: float):
	$AnimationPlayer.playback_speed = scale

func _on_AnimationPlayer_animation_finished(_anim_name: String):
	emit_signal("done")

func _on_Booger_Collider_area_entered(_area: Area2D):
	emit_signal("hit")

extends KinematicBody2D


func _on_AnimationPlayer_animation_finished(_Beam_Down):
	$"../The Alien (with OUTLINE shader)".visible = true
	$"../Shadow".visible = true
	$"../..".set_physics_process(true)
	queue_free()

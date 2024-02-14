extends Node2D

signal dialogue_finished

func _on_AnimationPlayer_animation_finished(_anim_name):
	emit_signal("dialogue_finished")

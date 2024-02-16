extends Node2D

signal animation_finished

func start_animation():
	$AnimationPlayer.play("techniker")
	yield($AnimationPlayer, "animation_finished")
	emit_signal("animation_finished")

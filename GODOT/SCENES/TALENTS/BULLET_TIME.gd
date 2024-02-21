extends Node2D

signal done

var running := false

func start(duration: float):
	$AnimationPlayer.play("bullet_time_on")
	var anim_off = $AnimationPlayer.get_animation("bullet_time_off")
	$Bullet_Timer.start(max(0, duration - anim_off.length))
	running = true

func stop():
	$AnimationPlayer.stop()
	$Bullet_Timer.stop()
	running = false

func is_running() -> bool:
	return running

func _on_Bullet_Timer_timeout():
	$AnimationPlayer.play("bullet_time_off")

func _on_animation_finished(anim_name):
	if anim_name == "bullet_time_off":
		running = false
		emit_signal("done")

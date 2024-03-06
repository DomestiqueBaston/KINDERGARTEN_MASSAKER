extends Node2D

# signal emitted when the Spit hits the alien
signal hit

# the spit projectile's direction and speed
var velocity: Vector2

# time scale for displacement
var time_scale := 1.0

func _physics_process(delta):
	position += velocity * delta * time_scale

func _on_Spit_Collilder_area_entered(_area: Area2D):
	emit_signal("hit")

func set_time_scale(scale: float):
	$AnimationPlayer.playback_speed = scale
	time_scale = scale

func pause():
	set_physics_process(false)
	$AnimationPlayer.stop(false)

func resume():
	set_physics_process(true)
	$AnimationPlayer.play()

extends Node2D

# Class implementing a projectile: an object that moves in a given direction and
# at a given speed until its animation finishes playing. It is assumed that each
# instance contains an AnimationPlayer node. Instances can connect physics
# objects or Area2D's to the on_hit_collider_*_entered() methods to detect when
# the projectile has hit something.

# signal emitted when the projectile hits something
signal hit

# signal emitted when the projectile's animation has finished
signal done

# the projectile's direction and speed
var velocity := Vector2.ZERO

# time scale for displacement
var time_scale := 1.0

#
# The velocity must be set before adding the projectile to the scene tree. If
# it is ZERO (the default), then physics processing is disabled.
#
func _ready():
	set_physics_process(velocity != Vector2.ZERO)

func _physics_process(delta):
	position += velocity * delta * time_scale

func on_hit_collider_area_entered(_area: Area2D):
	emit_signal("hit")

func on_hit_collider_body_entered(_body: Node):
	emit_signal("hit")

func on_animation_finished(_anim_name: String):
	emit_signal("done")

func set_time_scale(scale: float):
	$AnimationPlayer.playback_speed = scale
	time_scale = scale

func pause():
	set_physics_process(false)
	$AnimationPlayer.stop(false)

func resume():
	set_physics_process(true)
	$AnimationPlayer.play()

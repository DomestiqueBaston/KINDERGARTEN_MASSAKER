extends Node2D

# signal emitted when the Spit hits the alien
signal hit

# the spit projectile's direction and speed
var velocity: Vector2

func _physics_process(delta):
	position += velocity * delta

func _on_Spit_Collilder_area_entered(_area: Area2D):
	emit_signal("hit")

extends KinematicBody2D

func _ready():
	var orientation = Vector2(randi() % 3 - 1, randi() % 3 - 1)
	$AnimationTree["parameters/Idle/blend_position"] = orientation

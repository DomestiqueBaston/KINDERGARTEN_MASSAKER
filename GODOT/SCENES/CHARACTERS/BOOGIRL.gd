extends KinematicBody2D

func _ready():
	$AnimationTree["parameters/Idle/blend_position"] = Globals.get_random_direction()

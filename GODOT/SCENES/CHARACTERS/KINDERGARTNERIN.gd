extends KinematicBody2D

func _ready():
	$AnimationTree.active = true
	$AnimationTree["parameters/Check/blend_position"] = Globals.get_random_direction()

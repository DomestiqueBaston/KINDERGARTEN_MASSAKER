extends KinematicBody2D

func _ready():
	$AnimationTree.active = true
	$AnimationTree["parameters/Idle/blend_position"] = Globals.get_random_direction()

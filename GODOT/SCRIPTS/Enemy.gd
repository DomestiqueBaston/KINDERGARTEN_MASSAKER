extends KinematicBody2D

export var default_anim = "Idle"

var blend_param: String
var time_param: String

func _ready():
	$AnimationTree.active = true
	blend_param = "parameters/%s/BlendSpace2D/blend_position" % default_anim
	time_param = "parameters/%s/TimeScale/scale" % default_anim
	$AnimationTree[blend_param] = Globals.get_random_direction()

func freeze():
	$AnimationTree[time_param] = 0

func unfreeze():
	$AnimationTree[time_param] = 1

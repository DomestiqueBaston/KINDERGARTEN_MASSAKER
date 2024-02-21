extends KinematicBody2D

export var char_name: String
export var default_anim := "Idle"

var blend_param: String
var time_param: String

func _ready():
	$AnimationTree.active = true
	blend_param = "parameters/%s/BlendSpace2D/blend_position" % default_anim
	time_param = "parameters/%s/TimeScale/scale" % default_anim
	$AnimationTree[blend_param] = Globals.get_random_direction()

func set_time_scale(scale = 1.0):
	$AnimationTree[time_param] = scale

func freeze(flash=true):
	set_time_scale(0)
	if flash:
		$Flasher.play("flash")

func unfreeze(flash=true):
	set_time_scale(1)
	if flash:
		$Flasher.play("flash")

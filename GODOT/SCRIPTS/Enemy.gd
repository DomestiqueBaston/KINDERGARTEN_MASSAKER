extends KinematicBody2D

export var char_name: String
export var default_anim = "Idle"

const flash_time = 0.1

var blend_param: String
var time_param: String

func _ready():
	$AnimationTree.active = true
	blend_param = "parameters/%s/BlendSpace2D/blend_position" % default_anim
	time_param = "parameters/%s/TimeScale/scale" % default_anim
	$AnimationTree[blend_param] = Globals.get_random_direction()

func freeze():
	$AnimationTree[time_param] = 0
	_flash()

func unfreeze():
	$AnimationTree[time_param] = 1
	_flash()

func _flash():
	get_node(char_name).material.set_shader_param("flash", true)
	yield(get_tree().create_timer(flash_time), "timeout")
	get_node(char_name).material.set_shader_param("flash", false)

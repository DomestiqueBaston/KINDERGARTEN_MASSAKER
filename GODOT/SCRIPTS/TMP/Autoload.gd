extends Node


var transition_signal = false

var time_before_death = 25.0
var time_to_die = false

var elapsed_time = 0.0
var best_time = 0.0


func _physics_process(_delta):
# warning-ignore:return_value_discarded
	get_input()
	
func get_input():
	if Input.is_action_pressed('full_screen'):
		OS.window_fullscreen = !OS.window_fullscreen
		return true
	return false

extends Node2D


func get_input():
	if Input.is_action_pressed('full_screen'):
		OS.window_fullscreen = !OS.window_fullscreen
		return true
	return false


func _physics_process(_delta):
# warning-ignore:return_value_discarded
	get_input()
	

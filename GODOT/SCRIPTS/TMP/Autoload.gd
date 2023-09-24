extends Node


var choice = 0					#choix du pouvoir (DASH par défaut)

var transition_signal = false	#TRUE si Transition_Overlay a fini de jouer
var scene_changed = true		#TRUE quand on meurt
var restart_game = false		#TRUE quand on veut rejouer après être mort

var time_before_death = 50.0
var time_to_die = false			#TRUE quand on meurt (aussi ?)

# SCORE
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

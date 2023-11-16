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

const ignored_keys = [KEY_ALT, KEY_SHIFT, KEY_CONTROL, KEY_META, KEY_MENU]

#
# Returns true if the given event can be interpreted as "any key press" by a
# temporary screen which exits when "any key" is pressed. We have to explicitly
# ignore modifier keys, to avoid exiting when, for example, the Alt-Enter
# keyboard shortcut is used to toggle full-screen mode.
#
func event_is_key_press(event: InputEvent):
	return event.is_pressed() and not (
		event is InputEventKey and event.scancode in ignored_keys)

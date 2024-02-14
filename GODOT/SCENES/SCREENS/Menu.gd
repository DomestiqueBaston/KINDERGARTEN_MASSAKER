extends Node2D

signal start_game
signal show_tutorial
signal show_options
signal show_credits
signal exit_game
signal show_dialogue

enum MenuItem {
	TALENTS,
	TUTORIAL,
	OPTIONS,
	CREDITS,
	EXIT,
	DIALOGUE
}

# item count is 5 by default, 6 if the dialogue button is enabled
var item_count = 5
# index of the current item
var current_item = -1

func _ready():
	if current_item < 0:
		set_current_item(0)

func _unhandled_input(event):
	if event.is_action_pressed("ui_down"):
		$Control.get_node(current_item as String).self_modulate.a = 0
		current_item += 1
		if current_item >= item_count:
			current_item = 0
		$Control.get_node(current_item as String).self_modulate.a = 1
		SoundFX.playDown()
		get_tree().set_input_as_handled()
		
	elif event.is_action_pressed("ui_up"):
		$Control.get_node(current_item as String).self_modulate.a = 0
		current_item -= 1
		if current_item < 0:
			current_item = item_count - 1
		$Control.get_node(current_item as String).self_modulate.a = 1
		SoundFX.playUp()
		get_tree().set_input_as_handled()
		
	elif event.is_action_pressed("ui_accept", false, true):
		SoundFX.playOK()
		match current_item:
			MenuItem.TALENTS:
				emit_signal("start_game")
			MenuItem.TUTORIAL:
				emit_signal("show_tutorial")
			MenuItem.OPTIONS:
				emit_signal("show_options")
			MenuItem.CREDITS:
				emit_signal("show_credits")
			MenuItem.EXIT:
				emit_signal("exit_game")
			MenuItem.DIALOGUE:
				emit_signal("show_dialogue")
		get_tree().set_input_as_handled()

#
# Enables or disables the dialogue button. It is disabled by default.
#
func set_dialogue_enabled(enabled):
	if enabled:
		item_count = 6
		$Control/X.self_modulate.a = 1
	else:
		item_count = 5
		$Control/X.self_modulate.a = 0

#
# Sets the current (highlighted) item: see MenuItem.
#
func set_current_item(which):
	if current_item >= 0:
		$Control.get_node(current_item as String).self_modulate.a = 0
	current_item = which
	$Control.get_node(current_item as String).self_modulate.a = 1

#
# Returns the current (highlighted) item: see MenuItem.
#
func get_current_item():
	return current_item

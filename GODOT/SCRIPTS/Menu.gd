extends Node2D

signal start_game
signal show_tutorial
signal show_options
signal show_credits
signal exit_game
signal show_dialogue

# item count is 5 by default, 6 if the dialogue button is enabled
var item_count = 5
# index of the current item (the first, initially)
var current_item = 0

func _ready():
	# the first item is selected by default
	$"Control/0".self_modulate.a = 1

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
	elif event.is_action_pressed("ui_accept"):
		SoundFX.playOK()
		match current_item:
			0:
				emit_signal("start_game")
			1:
				emit_signal("show_tutorial")
			2:
				emit_signal("show_options")
			3:
				emit_signal("show_credits")
			4:
				emit_signal("exit_game")
			5:
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

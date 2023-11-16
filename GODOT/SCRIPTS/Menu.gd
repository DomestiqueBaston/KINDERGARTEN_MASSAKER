extends Node2D

signal start_game
signal show_options
signal show_credits
signal exit_game
signal show_dialogue

# item count is 3 by default, 4 if the dialogue button is enabled
var item_count = 3
# index of the current item (the first, initially)
var current_item = 0

func _ready():
	# the first item is selected by default
	$"Control/0".self_modulate.a = 1

func _unhandled_input(event):
	if event.is_action_pressed("ui_down"):
		if current_item < item_count:
			$Control.get_node(current_item as String).self_modulate.a = 0
			current_item += 1
			$Control.get_node(current_item as String).self_modulate.a = 1
		get_tree().set_input_as_handled()
	elif event.is_action_pressed("ui_up"):
		if current_item > 0:
			$Control.get_node(current_item as String).self_modulate.a = 0
			current_item -= 1
			$Control.get_node(current_item as String).self_modulate.a = 1
		get_tree().set_input_as_handled()

func _unhandled_key_input(event: InputEventKey):
	if Autoload.event_is_key_press(event):
		match current_item:
			0:
				emit_signal("start_game")
			1:
				emit_signal("show_options")
			2:
				emit_signal("show_credits")
			3:
				emit_signal("exit_game")
			4:
				emit_signal("show_dialogue")
		get_tree().set_input_as_handled()

#
# Enables or disables the dialogue button. It is disabled by default.
#
func set_dialogue_enabled(enabled):
	if enabled:
		item_count = 4
		$Control/X.self_modulate.a = 1
	else:
		item_count = 3
		$Control/X.self_modulate.a = 0

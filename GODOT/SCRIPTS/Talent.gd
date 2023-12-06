extends Node2D

signal talent_aborted
signal talent_chosen

# item count is 17 by default, 18 if Der Techniker is enabled
var item_count = 17
# note that 0 means nothing selected yet, the actual items start at 1
var current_item = 0
# 0 for the lefthand column, 1 for the righthand column
var current_column = 0

func _unhandled_input(event: InputEvent):
	var next_item = current_item
	
	if event.is_action_pressed("ui_down"):
		if current_item == 0:
			next_item = 1
		elif current_item == item_count:
			if current_column == 0:
				next_item = 1
			else:
				next_item = 2
		elif current_item == 17:
			next_item = 18
		elif current_item >= 15:
			next_item = 17
		else:
			next_item = current_item + 2
		SoundFX.playDown()
		get_tree().set_input_as_handled()
		
	elif event.is_action_pressed("ui_up"):
		if current_item <= 2:
			next_item = item_count
		elif current_item == 18:
			next_item = 17
		elif current_item == 17:
			if current_column == 0:
				next_item = 15
			else:
				next_item = 16
		else:
			next_item = current_item - 2
		SoundFX.playUp()
		get_tree().set_input_as_handled()
		
	elif event.is_action_pressed("ui_right"):
		next_item = current_item + 1
		if next_item > item_count:
			next_item = 1
		SoundFX.playDown()
		get_tree().set_input_as_handled()
		
	elif event.is_action_pressed("ui_left"):
		if current_item <= 1:
			next_item = item_count
		else:
			next_item = current_item - 1
		SoundFX.playUp()
		get_tree().set_input_as_handled()
		
	elif event.is_action_pressed("ui_accept", false, true):
		if current_item > 0:
			SoundFX.playOK()
			emit_signal("talent_chosen", current_item)
		get_tree().set_input_as_handled()
		
	elif event.is_action_pressed("ui_cancel"):
		SoundFX.playCancel()
		emit_signal("talent_aborted")
		get_tree().set_input_as_handled()
		
	if next_item != current_item:
		_set_current_item(next_item)

#
# Unhighlights the current item and highlights the given item, which is made
# the current item. Note that which is in the range [1 item_count].
#
func _set_current_item(which):
	if current_item > 0:
		_find_item(current_item).self_modulate.a = 0
	current_item = which
	if current_item > 0:
		_find_item(current_item).self_modulate.a = 1
	if current_item < 17:
		current_column = (current_item - 1) % 2

#
# Returns the control for the given item. Which is in the range [1 item_count].
#
func _find_item(which):
	var name = which as String
	if which < 10:
		name = "0" + name
	return $Control.find_node(name + "_*")

#
# Enables or disables the Der Techniker talent. It is disabled by default.
#
func set_techn_enabled(enabled):
	if enabled:
		item_count = 18
		$Techniker_Off.self_modulate.a = 1
	else:
		item_count = 17
		$Techniker_Off.self_modulate.a = 0

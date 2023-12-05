extends Node2D

var current_item = 0
const item_count = 4

func _ready():
	_update_volume(0, true)
	_update_volume(1, false)
	_update_volume(2, false)
	_update_complexity(false)

func _unhandled_input(event):
	var new_item = current_item
	if event.is_action_pressed("ui_down"):
		SoundFX.playDown()
		new_item = current_item + 1
		if new_item >= item_count:
			new_item = 0
		_set_current_item(new_item)
		get_tree().set_input_as_handled()
		
	elif event.is_action_pressed("ui_up"):
		SoundFX.playUp()
		new_item = current_item - 1
		if new_item < 0:
			new_item = item_count - 1
		_set_current_item(new_item)
		get_tree().set_input_as_handled()
		
	elif event.is_action_pressed("ui_left"):
		SoundFX.playUp()
		if current_item < 3:
			_adjust_volume(current_item, -5)
		else:
			_update_complexity(true)
		get_tree().set_input_as_handled()
		
	elif event.is_action_pressed("ui_right"):
		SoundFX.playDown()
		if current_item < 3:
			_adjust_volume(current_item, 5)
		else:
			_update_complexity(true)
		get_tree().set_input_as_handled()

#
# Adjusts one of the volume settings, then updates the corresponding UI item.
#
func _adjust_volume(which, how_much):
	var volume
	match which:
		0:
			volume = Settings.get_ambient_volume()
		1:
			volume = Settings.get_music_volume()
		2:
			volume = Settings.get_effects_volume()
	volume += how_much
	if volume < 0:
		volume = 0
	elif volume > 10:
		volume = 10
	match which:
		0:
			Settings.set_ambient_volume(volume)
		1:
			Settings.set_music_volume(volume)
		2:
			Settings.set_effects_volume(volume)
	_update_volume(which, true)

#
# Positions the "cursor" over the given item (there isn't actually a cursor,
# but the value on the line corresponding to the item is highlighted).
#
func _set_current_item(which):
	if current_item < 3:
		_update_volume(current_item, false)
	else:
		_update_complexity(false)
	current_item = which
	if current_item < 3:
		_update_volume(current_item, true)
	else:
		_update_complexity(true)

#
# Updates the appearance of the given volume control, depending on the current
# setting and on whether the user is positioned over it (is_current).
#
func _update_volume(which, is_current):
	var volume
	match which:
		0:
			volume = Settings.get_ambient_volume()
		1:
			volume = Settings.get_music_volume()
		2:
			volume = Settings.get_effects_volume()
	var volume_index
	if volume < 5:
		volume_index = 0
	elif volume < 10:
		volume_index = 1
	else:
		volume_index = 2
	for index in range(3):
		var selected_control = get_node("Control/%d_%d" % [which, index])
		var current_control = get_node("Control/%d_%d_valid" % [which, index])
		if index != volume_index:
			selected_control.self_modulate.a = 0
			current_control.self_modulate.a = 0
		elif is_current:
			selected_control.self_modulate.a = 1
			current_control.self_modulate.a = 0
		else:
			selected_control.self_modulate.a = 0
			current_control.self_modulate.a = 1

#
# Updates the appearance of the complexity control, depending only on whether
# the user is positioned over it, since he cannot modify it...
#
func _update_complexity(is_current):
	if is_current:
		$"Control/3_0".self_modulate.a = 1
		$"Control/3_0_valid".self_modulate.a = 0
	else:
		$"Control/3_0".self_modulate.a = 0
		$"Control/3_0_valid".self_modulate.a = 1

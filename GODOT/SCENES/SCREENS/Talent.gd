extends Node2D

signal talent_aborted
signal talent_chosen

# the number of items (some of which may be hidden)
const item_count = 23
# the current item (the "cursor")
var current_item = 0
# whether or not each item is visible
var item_visible = []
# 0 for the lefthand column, 1 for the righthand column
var current_column = 0
# has the user viewed the dialogue?
var dialogue_seen = false
# how long did the user survive previous games (in seconds)?
var survival_time = 0
# talent selected by the user
var selected_talent = 0

# mapping of UI items to the talents they represent
const ui_talent_map = [
	-1,
	Globals.Talent.TELEPORT,
	Globals.Talent.DASH,
	Globals.Talent.EXPLOSION,
	Globals.Talent.FORCE_FIELD,
	Globals.Talent.FREEZE,
	Globals.Talent.SPEED,
	Globals.Talent.TIME_STOP,
	Globals.Talent.MIRROR_IMAGE,
	Globals.Talent.SECOND_LIFE,
	Globals.Talent.DODGE,
	Globals.Talent.INVISIBLE,
	Globals.Talent.SHIELD,
	Globals.Talent.HEALTH,
	Globals.Talent.REGENERATE,
	Globals.Talent.RANGED_COMBAT,
	Globals.Talent.NONE,
	Globals.Talent.HAND_TO_HAND,
	Globals.Talent.RANDOM,
	Globals.Talent.VOMIT_PROOF,
	Globals.Talent.BULLET_TIME,
	Globals.Talent.GHOST,
	Globals.Talent.TECHNICIAN
]

func _ready():
	assert(ui_talent_map.size() == item_count)
	item_visible.resize(item_count)
	for i in item_count:
		item_visible[i] = (
			ui_talent_map[i] >= 0 and
			Globals.is_talent_enabled(
				ui_talent_map[i], dialogue_seen, survival_time))
	$Zufallig_Off.self_modulate.a = 1 if item_visible[18] else 0
	$Kotzsicher_Off.self_modulate.a = 1 if item_visible[19] else 0
	$Bullet_Time_Off.self_modulate.a = 1 if item_visible[20] else 0
	$Geist_Off.self_modulate.a = 1 if item_visible[21] else 0
	$Techniker_Off.self_modulate.a = 1 if item_visible[22] else 0
	_set_current_item(1)
	_hide_beam_me_down()

func _unhandled_input(event: InputEvent):
	var next_item = current_item
	
	if event.is_action_pressed("ui_down"):
		SoundFX.playDown()
		_hide_beam_me_down()
		next_item = _move_down()
		get_tree().set_input_as_handled()
		
	elif event.is_action_pressed("ui_up"):
		SoundFX.playUp()
		_hide_beam_me_down()
		next_item = _move_up()
		get_tree().set_input_as_handled()
		
	elif event.is_action_pressed("ui_left"):
		next_item = _move_left()
		if selected_talent > 0 or next_item != current_item:
			SoundFX.playUp()
		_hide_beam_me_down()
		get_tree().set_input_as_handled()
		
	elif event.is_action_pressed("ui_right"):
		next_item = _move_right()
		if selected_talent > 0 or next_item != current_item:
			SoundFX.playDown()
		_hide_beam_me_down()
		get_tree().set_input_as_handled()
		
	elif event.is_action_pressed("ui_accept", false, true):
		SoundFX.playOK()
		if selected_talent > 0:
			emit_signal("talent_chosen", ui_talent_map[selected_talent])
		else:
			_show_beam_me_down()
		get_tree().set_input_as_handled()
		
	elif event.is_action_pressed("ui_cancel"):
		SoundFX.playCancel()
		emit_signal("talent_aborted")
		get_tree().set_input_as_handled()
		
	if next_item != current_item:
		_set_current_item(next_item)

func _move_down():
	var item = current_item
	while item == current_item or not item_visible[item]:
		if item <= 15:
			item += 2
		elif item < item_count - 1:
			item += 1
		else:
			item = 1 if current_column == 0 else 2
	return item

func _move_up():
	var item = current_item
	while item == current_item or not item_visible[item]:
		if item >= 18:
			item -= 1
		elif item == 17:
			item = 15 if current_column == 0 else 16
		elif item >= 3:
			item -= 2
		else:
			item = item_count - 1
	return item

func _move_right():
	if current_item >= 1 and current_item <= 15 and current_column == 0:
		return current_item + 1
	else:
		return current_item

func _move_left():
	if current_item >= 2 and current_item <= 16 and current_column == 1:
		return current_item - 1
	else:
		return current_item

#
# Unhighlights the current item and highlights the given item, which is made
# the current item.
#
func _set_current_item(which):
	if current_item > 0:
		_find_item(current_item).self_modulate.a = 0
	current_item = which
	if current_item > 0:
		_find_item(current_item).self_modulate.a = 1
		if current_item <= 16:
			current_column = (current_item - 1) % 2

#
# Saves the current item as the selected talent and makes the Beam Me Down item
# visible.
#
func _show_beam_me_down():
	selected_talent = current_item
	$Beam_Me_Down_Off.self_modulate.a = 1
	_find_item(0).self_modulate.a = 1
	$AnimationPlayer.play("Beam_blink")

#
# Clears the selected talent and hides the Beam Me Down item.
#
func _hide_beam_me_down():
	selected_talent = 0
	$Beam_Me_Down_Off.self_modulate.a = 0
	_find_item(0).self_modulate.a = 0
	$AnimationPlayer.stop()

#
# Returns the control for the given item. Which is in the range [0 item_count).
#
func _find_item(which):
	var name = which as String
	if which < 10:
		name = "0" + name
	return $Control.find_node(name + "_*")

#
# Specifies whether or not the user has seen the dialogue, and how many seconds
# he has survived previous games. These two factors may unlock some talents
# which are otherwise hidden.
#
# Note that this must be called BEFORE the scene has been added to the tree,
# i.e. before _ready() is called.
#
func set_talent_level(dialogue_seen_, survival_time_):
	dialogue_seen = dialogue_seen_
	survival_time = survival_time_

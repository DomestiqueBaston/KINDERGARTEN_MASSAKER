extends Node2D

signal start_game
signal show_options
signal show_credits
signal exit_game
signal show_dialogue

var item_count = 3
var current_item = 0
var dialogue_enabled = false

func _ready():
	current_item = 0
	$Control.find_node("0").self_modulate.a = 1

func _unhandled_input(event):
	if event.is_action_pressed("ui_down"):
		if current_item < item_count:
			$Control.find_node(current_item as String).self_modulate.a = 0
			current_item += 1
			$Control.find_node(current_item as String).self_modulate.a = 1
	elif event.is_action_pressed("ui_up"):
		if current_item > 0:
			$Control.find_node(current_item as String).self_modulate.a = 0
			current_item -= 1
			$Control.find_node(current_item as String).self_modulate.a = 1
	elif event.is_pressed():
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

func set_dialogue_enabled(enabled):
	if enabled:
		item_count = 4
		$Control/X.self_modulate.a = 1
	else:
		item_count = 3
		$Control/X.self_modulate.a = 0

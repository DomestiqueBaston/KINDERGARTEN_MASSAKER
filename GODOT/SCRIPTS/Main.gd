extends Node2D

var menu = preload("res://SCENES/SCREENS/Menu.tscn")
var tutorial = preload("res://SCENES/SCREENS/Tuto.tscn")
var options = preload("res://SCENES/SCREENS/Options.tscn")
var credits = preload("res://SCENES/SCREENS/Credits.tscn")
var dialogue = preload("res://SCENES/SCREENS/Dialogue.tscn")
var talent = preload("res://SCENES/SCREENS/Talent.tscn")

var credits_seen = false
var dialogue_seen = false

enum GameState {
	TITLE,
	MENU,
	TUTORIAL,
	OPTIONS,
	CREDITS,
	DIALOGUE,
	TALENT
}

var state = GameState.TITLE

func _ready():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var overlay_path = "res://SCENES/OVERLAYS/Game_Overlay_%d.tscn" % rng.randi_range(1, 4)
	var overlay_scene = load(overlay_path)
	$PAPA_Game_Overlay.add_child(overlay_scene.instance())

func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("full_screen"):
		OS.window_fullscreen = !OS.window_fullscreen
		get_tree().set_input_as_handled()
	elif state == GameState.TITLE and event.is_action_pressed("ui_accept"):
		SoundFX.playOK()
		change_state(GameState.MENU)
		get_tree().set_input_as_handled()
	elif state != GameState.MENU and event.is_action_pressed("ui_cancel"):
		SoundFX.playCancel()
		if state == GameState.OPTIONS:
			Settings.save_settings()
		change_state(GameState.MENU)
		get_tree().set_input_as_handled()

func change_state(next_state):
	$Transition_Overlay.show()
	$Transition_Overlay.start_transition()
	$Active_Scene.get_child(0).queue_free()
	var child
	match next_state:
		GameState.MENU:
			child = menu.instance()
			child.set_dialogue_enabled(credits_seen)
			child.connect("start_game", self, "on_start_game")
			child.connect("show_tutorial", self, "on_show_tutorial")
			child.connect("show_options", self, "on_show_options")
			child.connect("show_credits", self, "on_show_credits")
			child.connect("exit_game", self, "on_exit_game")
			child.connect("show_dialogue", self, "on_show_dialogue")
		GameState.TUTORIAL:
			child = tutorial.instance()
		GameState.OPTIONS:
			child = options.instance()
		GameState.CREDITS:
			child = credits.instance()
			credits_seen = true
		GameState.DIALOGUE:
			child = dialogue.instance()
			child.connect("dialogue_finished", self, "on_dialogue_finished")
		GameState.TALENT:
			child = talent.instance()
			child.set_techn_enabled(dialogue_seen)
			child.connect("talent_aborted", self, "on_talent_aborted")
			child.connect("talent_chosen", self, "on_talent_chosen")
	$Active_Scene.add_child(child)
	state = next_state

func _on_Transition_Overlay_transition_finished():
	$Transition_Overlay.hide()

func on_dialogue_finished():
	dialogue_seen = true
	change_state(GameState.MENU)

func on_start_game():
	change_state(GameState.TALENT)

func on_show_tutorial():
	change_state(GameState.TUTORIAL)

func on_show_options():
	change_state(GameState.OPTIONS)

func on_show_credits():
	change_state(GameState.CREDITS)

func on_show_dialogue():
	change_state(GameState.DIALOGUE)

func on_talent_aborted():
	change_state(GameState.MENU)

func on_talent_chosen(talent_index):
	print("chose talent: ", talent_index)
	# TODO
	change_state(GameState.MENU)

func on_exit_game():
	get_tree().quit(0)

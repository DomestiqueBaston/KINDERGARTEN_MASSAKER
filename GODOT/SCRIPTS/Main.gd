extends Node2D

# determines how quickly the camera follows the alien's movements
export var camera_speed = 5

var menu = preload("res://SCENES/SCREENS/Menu.tscn")
var tutorial = preload("res://SCENES/SCREENS/Tuto.tscn")
var options = preload("res://SCENES/SCREENS/Options.tscn")
var credits = preload("res://SCENES/SCREENS/Credits.tscn")
var dialogue = preload("res://SCENES/SCREENS/Dialogue.tscn")
var talent = preload("res://SCENES/SCREENS/Talent.tscn")
var background = preload("res://SCENES/BACKGROUND/Background.tscn")
var alien = preload("res://SCENES/CHARACTERS/ALIEN.tscn")

var credits_seen = false
var dialogue_seen = false

enum GameState {
	TITLE,
	MENU,
	TUTORIAL,
	OPTIONS,
	CREDITS,
	DIALOGUE,
	TALENT,
	PLAY
}

var state = GameState.TITLE
var previous_menu_item = -1
var player
var overlay

func _ready():
	set_process(false)
	var overlay_path = "res://SCENES/OVERLAYS/Game_Overlay_%d.tscn" % (1 + randi() % 4)
	var overlay_scene = load(overlay_path)
	overlay = overlay_scene.instance()
	$PAPA_Game_Overlay.add_child(overlay)

func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("full_screen"):
		OS.window_fullscreen = !OS.window_fullscreen
		get_tree().set_input_as_handled()
		
	# user can go back to main menu by pressing ui_accept, ui_cancel or most
	# keyboard keys (symbols such as letters, numbers and punctuation)
	
	elif (state != GameState.MENU and state != GameState.PLAY and
			(event.is_action_pressed("ui_accept", false, true) or
			event.is_action_pressed("ui_cancel") or
			(event is InputEventKey and event.is_pressed() and
				event.scancode >= KEY_SPACE and event.scancode <= 255))):
		if event.is_action_pressed("ui_accept", false, true):
			SoundFX.playOK()
		else:
			SoundFX.playCancel()
		if state == GameState.OPTIONS:
			Settings.save_settings()
		change_state(GameState.MENU)
		get_tree().set_input_as_handled()

func _process(delta):
	if player:
		var lerp_weight = clamp(camera_speed * delta, 0.0, 1.0)
		$Camera.position = lerp($Camera.position, player.position, lerp_weight)

func change_state(next_state):
	var child = $Active_Scene.get_child(0)
	if state == GameState.MENU:
		previous_menu_item = child.get_current_item()
		
	# hide overlay before $Transition_Overlay takes a screenshot
	$PAPA_Game_Overlay.hide()
	$Transition_Overlay.show()
	$Transition_Overlay.start_transition()
	# put overlay back after screenshot has been taken
	$PAPA_Game_Overlay.show()
	
	child.queue_free()
	child = null
	
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
			if previous_menu_item >= 0:
				child.set_current_item(previous_menu_item)
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
			child.set_talent_level(dialogue_seen, 100)
			child.connect("talent_aborted", self, "on_talent_aborted")
			child.connect("talent_chosen", self, "on_talent_chosen")
		GameState.PLAY:
			child = background.instance()
			prepare_game(child)
	
	if child:
		$Active_Scene.add_child(child)
	
	state = next_state

func _on_Transition_Overlay_transition_finished():
	$Transition_Overlay.hide()
	if state == GameState.PLAY:
		start_game($Active_Scene.get_child(0))

func on_dialogue_finished():
	# Without this pause, when the dialogue -> menu transition begins in full
	# screen mode, the menu sometimes appears for a frame before it disappears
	# and then fades in as it should. Perhaps we should always pause for a
	# frame before triggering a transition...?
	yield(get_tree(), "idle_frame")
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
	print("chose talent: ", Globals.talent_name[talent_index])
	change_state(GameState.PLAY)

func on_exit_game():
	get_tree().quit(0)

#
# Stuff to do when the background has been instanced but before the game
# actually starts: determine where the alien will appear, and put the camera
# there.
#
func prepare_game(bg):
	$Camera.position = bg.get_alien_starting_point()
	$Camera.current = true

#
# Start the game: populate the scene with an alien and his enemies.
#
func start_game(bg):

	# instantiate the alien and position him in front of the camera, initially

	player = alien.instance()
	player.position = $Camera.position
	bg.add_child(player)

	# activate the camera that follows the alien around

	set_process(true)

	# wait for the beam down animation to finish before starting the overlay
	# animation which will eventually make it impossible to see

	yield(player, "beam_down_finished")

	# some overlay nodes have several animation players, so find them all

	var anim_players = []
	for child in overlay.get_children():
		if child.is_class("AnimationPlayer"):
			anim_players.append(child)

	# pick one of the animation players at random

	var anim_player
	if anim_players.size() == 1:
		anim_player = anim_players[0]
	elif anim_players.size() > 1:
		var which = randi() % anim_players.size()
		anim_player = anim_players[which]

	# start its first animation playing (other than RESET)

	if anim_player:
		var anim_name
		for a in anim_player.get_animation_list():
			if a != "RESET":
				anim_name = a
				break
		if anim_name:
			print("starting animation: %s/%s/%s" %
				[overlay.name, anim_player.name, anim_name])
			anim_player.play(anim_name)

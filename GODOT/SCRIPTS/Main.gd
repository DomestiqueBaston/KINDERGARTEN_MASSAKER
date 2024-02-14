extends Node2D

# determines how quickly the camera follows the alien's movements
export var camera_speed = 5.0

# after how many seconds is the first new enemy spawned?
export var spawn_first_time = 5.0

# every how many seconds are new enemies spawned subsequently?
export var spawn_cycle_time = 2.0

var menu_scene = preload("res://SCENES/SCREENS/Menu.tscn")
var tutorial_scene = preload("res://SCENES/SCREENS/Tuto.tscn")
var options_scene = preload("res://SCENES/SCREENS/Options.tscn")
var credits_scene = preload("res://SCENES/SCREENS/Credits.tscn")
var dialogue_scene = preload("res://SCENES/SCREENS/Dialogue.tscn")
var talent_scene = preload("res://SCENES/SCREENS/Talent.tscn")
var death_scene = preload("res://SCENES/SCREENS/Death.tscn")
var background_scene = preload("res://SCENES/BACKGROUND/Background.tscn")
var alien_scene = preload("res://SCENES/CHARACTERS/ALIEN.tscn")
var teacher_scene = preload("res://SCENES/CHARACTERS/KINDERGARTNERIN.tscn")
var crying_kid_scene = preload("res://SCENES/CHARACTERS/BINOCLARD.tscn")
var vomiting_kid_scene = preload("res://SCENES/CHARACTERS/VOMITO.tscn")
var booger_kid_scene = preload("res://SCENES/CHARACTERS/BOOGIRL.tscn")
var stick_kid_scene = preload("res://SCENES/CHARACTERS/BLONDINET.tscn")
var spitting_kid_scene = preload("res://SCENES/CHARACTERS/CRACHEUSE.tscn")

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
	PLAY,
	DEATH
}

var state = GameState.TITLE
var previous_menu_item = -1
var overlay: Node
var background: Background
var alien: Node

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

	elif state == GameState.PLAY:
		if event.is_action_pressed("ui_cancel"):
			stop_game()
			change_state(GameState.DEATH)
			get_tree().set_input_as_handled()

	# user can go back to main menu by pressing ui_accept, ui_cancel or most
	# keyboard keys (symbols such as letters, numbers and punctuation)
	
	elif (state != GameState.MENU and
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
	if alien:
		update_camera(delta)

func _get_window_size() -> Vector2:
	return Vector2(
		ProjectSettings.get_setting("display/window/size/width"),
		ProjectSettings.get_setting("display/window/size/height"))

#
# Called by _process() to update the camera, which follows the alien's position.
# Rather than snapping directly to the target position, the camera moves toward
# the target position more or less gradually, depending on camera_speed. Also,
# the camera refuses to move outside the limits of the background scene.
#
func update_camera(delta):
	var limits = background.get_limits()
	var size = _get_window_size()
	var w = size.x / 2.0
	var h = size.y / 2.0
	var x = clamp(alien.position.x, limits.position.x + w, limits.end.x - w)
	var y = clamp(alien.position.y, limits.position.y + h, limits.end.y - h)
	var lerp_weight = clamp(camera_speed * delta, 0.0, 1.0)
	$Camera.position = lerp($Camera.position, Vector2(x, y), lerp_weight)

func change_state(next_state):
	var child = $Active_Scene.get_child(0)
	
	if state == GameState.MENU:
		previous_menu_item = child.get_current_item()
	elif state == GameState.DEATH:
		$Menu_Music.play()

	if next_state != GameState.DEATH:
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
			child = menu_scene.instance()
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
			child = tutorial_scene.instance()
		GameState.OPTIONS:
			child = options_scene.instance()
		GameState.CREDITS:
			child = credits_scene.instance()
			credits_seen = true
		GameState.DIALOGUE:
			child = dialogue_scene.instance()
			child.connect("dialogue_finished", self, "on_dialogue_finished")
		GameState.TALENT:
			child = talent_scene.instance()
			child.set_talent_level(dialogue_seen, 100)
			child.connect("talent_aborted", self, "on_talent_aborted")
			child.connect("talent_chosen", self, "on_talent_chosen")
		GameState.PLAY:
			child = background_scene.instance()
			background = child
			prepare_game()
		GameState.DEATH:
			child = death_scene.instance()
	
	if child:
		$Active_Scene.add_child(child)
	
	state = next_state

func _on_Transition_Overlay_transition_finished():
	$Transition_Overlay.hide()
	if state == GameState.PLAY:
		start_game()

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
# actually starts: determine where the alien will appear, put the camera there,
# and populate the scene with bad guys.
#
func prepare_game():

	# position the camera where the alien will appear

	$Camera.position = background.get_alien_starting_point()

	# add teacher and initial kids, ensuring they are on camera (or not far
	# off-camera...)

	var window_size = _get_window_size() * 1.5
	var bbox = Rect2($Camera.position - window_size / 2.0, window_size)

	var positions = background.get_spawning_points(9, bbox)
	background.instance_character_at(teacher_scene, positions[0])
	background.instance_character_at(crying_kid_scene, positions[1])
	background.instance_character_at(vomiting_kid_scene, positions[2])
	background.instance_character_at(booger_kid_scene, positions[3])
	background.instance_character_at(stick_kid_scene, positions[4])
	background.instance_character_at(stick_kid_scene, positions[5])
	background.instance_character_at(stick_kid_scene, positions[6])
	background.instance_character_at(spitting_kid_scene, positions[7])
	background.instance_character_at(spitting_kid_scene, positions[8])

#
# Start the game: beam down the alien, change the music, and track the alien
# with the camera.
#
func start_game():

	# instantiate the alien and position him in front of the camera, initially

	alien = background.instance_character_at(alien_scene, $Camera.position)

	# from now on, the camera follows the alien's movements

	set_process(true)

	# stop menu music, start background noise and intro music (game music
	# starts when intro music finishes)

	$Menu_Music.stop()
	$Background_Sound.play()
	$Intro_Music.play()

	# wait for the beam down animation to finish before starting the overlay
	# animation which will eventually make it impossible to see

	yield(alien, "beam_down_finished")
	overlay.start_animation()

	# start spawning enemies and counting down

	$Enemy_Timer.start(spawn_first_time)
	$Shutdown_Timer.start()

func _on_Intro_Music_finished():
	$Game_Music.play()

func _on_Enemy_Timer_timeout():

	# find a spawning point off-camera

	var window_size = _get_window_size()
	var bbox = Rect2($Camera.position - window_size / 2.0, window_size)
	var pos = background.get_spawning_point(null, bbox)

	# what sort of enemy?

	var enemy_scene: PackedScene
	var rand = randf()
	if rand < 0.25:
		enemy_scene = spitting_kid_scene
	elif rand < 0.55:
		enemy_scene = stick_kid_scene
	elif rand < 0.74:
		enemy_scene = booger_kid_scene
	elif rand < 0.87:
		enemy_scene = crying_kid_scene
	else:
		enemy_scene = vomiting_kid_scene

	# spawn the enemy and reset the timer for 3 seconds

	background.instance_character_at(enemy_scene, pos)
	$Enemy_Timer.start(spawn_cycle_time)

func _on_Shutdown_Timer_timeout():
	$Shutdown_Overlay.visible = true
	$Shutdown_Overlay.start_animation()
	yield($Shutdown_Overlay, "animation_started")
	overlay.reset_animation()

func stop_game():
	$Camera.position = _get_window_size() / 2.0
	set_process(false)
	$Background_Sound.stop()
	$Intro_Music.stop()
	$Game_Music.stop()
	$Enemy_Timer.stop()
	$Shutdown_Timer.stop()
	$Shutdown_Overlay.visible = false
	$Shutdown_Overlay.reset_animation()
	overlay.reset_animation()

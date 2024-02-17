extends Node2D

# determines how quickly the camera follows the alien's movements
export var camera_speed = 5.0

# after how many seconds is the first new enemy spawned?
export var spawn_first_time = 5.0

# every how many seconds are new enemies spawned subsequently?
export var spawn_cycle_time = 2.0

# how many kids are placed initially on camera
export var kids_on_camera = 8

# how many kids are placed initially off camera
export var kids_off_camera = 16

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
var alien: Alien
var enemies: Node2D
var talent = -1
var techniker_used = false

func _ready():
	set_process(false)
	_set_game_overlay()
	alien = $Characters/ALIEN
	enemies = $Characters/Enemies

#
# Chooses a game overlay scene at random and adds it below PAPA_Game_Overlay.
# If there is already an overlay, it is removed.
#
func _set_game_overlay():
	var overlay_path = "res://SCENES/OVERLAYS/Game_Overlay_%d.tscn" % (1 + randi() % 4)
	var overlay_scene = load(overlay_path)
	if overlay:
		overlay.queue_free()
	overlay = overlay_scene.instance()
	print("game overlay: " + overlay.name)
	$PAPA_Game_Overlay.add_child(overlay)

func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("full_screen"):
		OS.window_fullscreen = !OS.window_fullscreen
		get_tree().set_input_as_handled()

	# during the game: ui_cancel to interrupt, ui_accept to use talent

	elif state == GameState.PLAY:
		if not $ScoreTracker.is_playing():
			pass
		elif (event.is_action_pressed("ui_accept", false, true)
			and $Cooldown_Timer.is_stopped()):
			match talent:
				Globals.Talent.TELEPORT:
					start_teleport()
				Globals.Talent.DASH:
					start_dash()
				Globals.Talent.SHIELD:
					start_shield()
				Globals.Talent.TECHNICIAN:
					if not $Shutdown_Overlay.visible:
						techniker()
			get_tree().set_input_as_handled()
		elif event.is_action_pressed("ui_cancel"):
			stop_game()
			change_state(GameState.DEATH)
			get_tree().set_input_as_handled()

	# ui_accept from DEATH starts a new game directly

	elif (state == GameState.DEATH and
			event.is_action_pressed("ui_accept", false, true)):
		change_state(GameState.PLAY)
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
			if state == GameState.DEATH:
				_set_game_overlay()
		if state == GameState.OPTIONS:
			Settings.save_settings()
		change_state(GameState.MENU)
		get_tree().set_input_as_handled()

func _process(delta):
	update_camera(delta)
	if talent == Globals.Talent.DASH:
		update_dash_trail()

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
			child.set_talent_level(
				dialogue_seen, $ScoreTracker.get_best_score())
			child.connect("talent_aborted", self, "on_talent_aborted")
			child.connect("talent_chosen", self, "on_talent_chosen")
		GameState.PLAY:
			child = background_scene.instance()
			background = child
			prepare_game()
		GameState.DEATH:
			child = death_scene.instance()
			child.best_time = $ScoreTracker.get_best_score()
			child.elapsed_time = $ScoreTracker.get_last_score()
	
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
	talent = talent_index
	print("chose talent: ", Globals.talent_name[talent_index])
	change_state(GameState.PLAY)

func on_exit_game():
	get_tree().quit(0)

func instance_character_at(scene: PackedScene, pos: Vector2) -> Node:
	var inst = scene.instance()
	inst.position = pos
	enemies.add_child(inst)
	return inst

func get_random_kid() -> PackedScene:
	var rand = randf()
	if rand < 0.25:
		return spitting_kid_scene
	elif rand < 0.55:
		return stick_kid_scene
	elif rand < 0.74:
		return booger_kid_scene
	elif rand < 0.87:
		return crying_kid_scene
	else:
		return vomiting_kid_scene

#
# Stuff to do when the background has been instanced but before the game
# actually starts: determine where the alien will appear, put the camera there,
# and populate the scene with bad guys.
#
func prepare_game():

	# position the camera and the alien

	var pos = background.get_alien_starting_point()
	alien.set_fast_run_cycle(talent == Globals.Talent.SPEED)
	alien.position = pos
	$Camera.position = pos

	# add teacher and some kids, on camera (or not far off-camera...)

	var window_size = _get_window_size() * 1.5
	var bbox = Rect2(pos - window_size / 2.0, window_size)

	var positions = background.get_spawning_points(1 + kids_on_camera, bbox)
	instance_character_at(teacher_scene, positions[0])
	for i in range(1, kids_on_camera + 1):
		instance_character_at(get_random_kid(), positions[i])

	# add more kids off camera

	positions = background.get_spawning_points(kids_off_camera, null, bbox)
	for i in range(kids_off_camera):
		instance_character_at(get_random_kid(), positions[i])

#
# Start the game: beam down the alien, change the music, and track the alien
# with the camera.
#
func start_game():

	# instantiate the alien and position him in front of the camera, initially

	alien.beam_down()
	alien.show()

	# from now on, the camera follows the alien's movements

	set_process(true)

	# stop menu music, start background noise and intro music (game music
	# starts when intro music finishes)

	$Menu_Music.stop()
	$Background_Sound.play()
	$Intro_Music.play()

	# wait for the beam down animation to finish before starting the overlay
	# animation, which will eventually make it impossible to see, spawning
	# enemies and counting down

	yield(alien, "beam_down_finished")
	overlay.start_animation()
	$Enemy_Timer.start(spawn_first_time)
	$Shutdown_Timer.start()
	$ScoreTracker.start_game()

func _on_Intro_Music_finished():
	if state == GameState.PLAY:
		$Game_Music.play()

func _on_Enemy_Timer_timeout():
	if state != GameState.PLAY:
		return

	# find a spawning point off-camera

	var window_size = _get_window_size() * 1.5
	var bbox = Rect2($Camera.position - window_size / 2.0, window_size)
	var pos = background.get_spawning_point(null, bbox)

	# spawn the enemy and restart the timer

	instance_character_at(get_random_kid(), pos)
	$Enemy_Timer.start(spawn_cycle_time)

func _on_Shutdown_Timer_timeout():
	$Shutdown_Overlay.show()
	$Shutdown_Overlay.start_animation()
	yield($Shutdown_Overlay, "animation_started")
	overlay.reset_animation()

func stop_game():
	$ScoreTracker.stop_game()
	
	$Camera.position = _get_window_size() / 2.0
	set_process(false)
	
	$Background_Sound.stop()
	$Intro_Music.stop()
	$Game_Music.stop()
	$Enemy_Timer.stop()
	$Shutdown_Timer.stop()
	$Shutdown_Overlay.hide()
	$Shutdown_Overlay.reset_animation()
	$Cooldown_Timer.stop()
	
	match talent:
		Globals.Talent.DASH:
			stop_dash()
		Globals.Talent.TECHNICIAN:
			techniker_used = false
	
	overlay.reset_animation()
	
	alien.hide()
	alien.reset()
	for enemy in enemies.get_children():
		enemy.queue_free()

func start_teleport():
	alien.start_teleport()
	alien.start_cooldown()
	$Cooldown_Timer.start(Globals.talent_cooldown[talent])

func teleport():
	alien.position = background.get_teleportation_point()

func start_dash():
	alien.start_dash()
	$FX/Dash_Trail.show()
	$FX/Dash_Timer.start()
	alien.start_cooldown()
	$Cooldown_Timer.start(Globals.talent_cooldown[talent])

func update_dash_trail():
	if $FX/Dash_Trail.visible:
		$FX/Dash_Trail.add_point(alien.position)
		while $FX/Dash_Trail.get_point_count() > 50:
			$FX/Dash_Trail.remove_point(0)

func stop_dash():
	alien.stop_dash()
	$FX/Dash_Trail.hide()
	$FX/Dash_Trail.clear_points()
	$FX/Dash_Timer.stop()

func start_shield():
	alien.start_cooldown()
	$Cooldown_Timer.start(Globals.talent_cooldown[talent])
	$Characters/ALIEN/Shield.show()
	$Characters/ALIEN/Shield/AnimationPlayer.play("shield")
	yield($Characters/ALIEN/Shield/AnimationPlayer, "animation_finished")
	$Characters/ALIEN/Shield.hide()

func techniker():
	if techniker_used:
		return
	techniker_used = true
	$Shutdown_Timer.stop()
	$Techniker.position = $Camera.position
	$Techniker.show()
	$Techniker/AnimationPlayer.play("techniker")
	yield($Techniker/AnimationPlayer, "animation_finished")
	overlay.rewind_animation()
	$Techniker.hide()

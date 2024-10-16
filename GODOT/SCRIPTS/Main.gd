extends Node2D

# unlock all talents immediately
export var unlock_all_talents := false

# true => turn off overlay animation
export var block_overlay_animation := false

# determines how quickly the camera follows the alien's movements
export var camera_speed := 5.0

# after how many seconds is the first new enemy spawned?
export var spawn_first_time := 5.0

# every how many seconds are new enemies spawned subsequently?
export var spawn_cycle_time := 2.0

# how many kids are placed initially on camera
export var kids_on_camera := 8

# how many kids are placed initially off camera
export var kids_off_camera := 16

# talent settings
export var TELEPORT_cooldown := 10
export var DASH_cooldown := 15
export var DASH_duration := 0.25
export var DASH_run_speed := 5
export var DASH_run_cycle_speed := 2
export var EXPLOSION_cooldown := 10
export var EXPLOSION_distance := 100
export var EXPLOSION_duration := 0.5
export var EXPLOSION_radius := 135
export var FREEZE_cooldown := 15
export var FREEZE_duration := 4
export var FREEZE_radius := 135
export var SPEED_run_speed := 1.2
export var SPEED_run_cycle_speed := 1.2
export var FORCE_FIELD_cooldown := 10
export var FORCE_FIELD_duration := 6
export var TIME_STOP_cooldown := 20
export var TIME_STOP_duration := 3
export var MIRROR_IMAGE_cooldown := 15
export var MIRROR_IMAGE_duration := 3
export var INVISIBLE_cooldown := 20
export var INVISIBLE_duration := 4
export var SHIELD_cooldown := 10
export var SHIELD_duration := 3
export var BULLET_TIME_cooldown := 15
export var BULLET_TIME_duration := 3
export var BULLET_TIME_slowdown := 0.5
export var GHOST_cooldown := 20

var menu_scene := preload("res://SCENES/SCREENS/Menu.tscn")
var tutorial_scene := preload("res://SCENES/SCREENS/Tuto.tscn")
var options_scene := preload("res://SCENES/SCREENS/Options.tscn")
var credits_scene := preload("res://SCENES/SCREENS/Credits.tscn")
var dialogue_scene := preload("res://SCENES/SCREENS/Dialogue.tscn")
var talent_scene := preload("res://SCENES/SCREENS/Talent.tscn")
var death_scene := preload("res://SCENES/SCREENS/Death.tscn")
var background_scene := preload("res://SCENES/BACKGROUND/Background.tscn")
var alien_scene := preload("res://SCENES/CHARACTERS/ALIEN.tscn")
var teacher_scene := preload("res://SCENES/CHARACTERS/KINDERGARTNERIN.tscn")
var crying_kid_scene := preload("res://SCENES/CHARACTERS/BINOCLARD.tscn")
var vomiting_kid_scene := preload("res://SCENES/CHARACTERS/VOMITO.tscn")
var booger_kid_scene := preload("res://SCENES/CHARACTERS/BOOGIRL.tscn")
var stick_kid_scene := preload("res://SCENES/CHARACTERS/BLONDINET.tscn")
var spitting_kid_scene := preload("res://SCENES/CHARACTERS/CRACHEUSE.tscn")
var vomit_scene := preload("res://SCENES/FX/Vomit.tscn")

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

var state: int = GameState.TITLE
var previous_menu_item := -1
var overlay: Node
var background: Background
var alien: Alien
var teacher: Enemy
var chosen_talent := -1
var actual_talent := -1
var techniker_used := false

func _ready():
	set_process(false)
	_set_game_overlay()

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
	if Globals.VERBOSE:
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
			  and not alien.is_cooldown_active()
			  and not alien.is_busy()):
			match actual_talent:
				Globals.Talent.TELEPORT:
					start_teleport()
				Globals.Talent.DASH:
					start_dash()
				Globals.Talent.EXPLOSION:
					start_explosion()
				Globals.Talent.FREEZE:
					start_freeze()
				Globals.Talent.FORCE_FIELD:
					start_force_field()
				Globals.Talent.TIME_STOP:
					start_time_stop()
				Globals.Talent.MIRROR_IMAGE:
					start_mirror_images()
				Globals.Talent.INVISIBLE:
					start_invisible()
				Globals.Talent.SHIELD:
					start_shield()
				Globals.Talent.TECHNICIAN:
					start_techniker()
				Globals.Talent.BULLET_TIME:
					start_bullet_time()
				Globals.Talent.GHOST:
					start_ghost()
			get_tree().set_input_as_handled()
		elif event.is_action_pressed("ui_cancel"):
			stop_game()
			change_state(GameState.DEATH)
			get_tree().set_input_as_handled()

	# ui_accept from DEATH starts a new game directly

	elif (state == GameState.DEATH and
			event.is_action_pressed("ui_accept", false, true)):
		_set_game_overlay()
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
		change_state(GameState.MENU)
		get_tree().set_input_as_handled()

func _process(delta):
	update_camera(delta)
	if actual_talent == Globals.Talent.DASH:
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
	var w = $Camera.zoom.x * size.x / 2.0
	var h = $Camera.zoom.y * size.y / 2.0
	var x = clamp(alien.position.x, limits.position.x + w, limits.end.x - w)
	var y = clamp(alien.position.y, limits.position.y + h, limits.end.y - h)
	var lerp_weight = clamp(camera_speed * delta, 0.0, 1.0)
	$Camera.position = lerp($Camera.position, Vector2(x, y), lerp_weight)

func change_state(next_state):
	var child = $Active_Scene.get_child(0)
	
	# remember current menu item
	
	if state == GameState.MENU:
		previous_menu_item = child.get_current_item()

	# trigger a visual transition to the next screen (except when dying)

	if next_state != GameState.DEATH:
		# hide overlay before $Transition_Overlay takes a screenshot
		$PAPA_Game_Overlay.hide()
		$Transition_Overlay.show()
		$Transition_Overlay.start_transition()
		# put overlay back after screenshot has been taken
		$PAPA_Game_Overlay.show()
	
	# replace the current active scene with a new instance of the next one
	
	child.queue_free()
	child = null
	
	match next_state:
		GameState.MENU:
			child = menu_scene.instance()
			child.set_dialogue_enabled(Settings.get_watched_credits())
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
			Settings.set_watched_credits(true)
		GameState.DIALOGUE:
			child = dialogue_scene.instance()
			child.connect("dialogue_finished", self, "on_dialogue_finished")
		GameState.TALENT:
			child = talent_scene.instance()
			if unlock_all_talents:
				child.set_talent_level(true, 100)
			else:
				child.set_talent_level(
					Settings.get_watched_dialogue(), Settings.get_best_score())
			child.connect("talent_aborted", self, "on_talent_aborted")
			child.connect("talent_chosen", self, "on_talent_chosen")
		GameState.PLAY:
			child = background_scene.instance()
			background = child
			prepare_game()
		GameState.DEATH:
			child = death_scene.instance()
			child.best_time = Settings.get_best_score()
			child.elapsed_time = $ScoreTracker.get_last_score()
	
	if child != null:
		$Active_Scene.add_child(child)
	
	state = next_state
	
	# make sure the menu music is always playing (outside of the game)

	if (not state in [GameState.PLAY, GameState.DEATH] and
		not $Audio/Menu_Music.playing):
		$Audio/Menu_Music.play()
	
	# don't allow the player to leave the death screen immediately
	
	if state == GameState.DEATH:
		set_process_unhandled_input(false)
		yield(get_tree().create_timer(1), "timeout")
		set_process_unhandled_input(true)

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
	Settings.set_watched_dialogue(true)
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
	chosen_talent = talent_index
	if Globals.VERBOSE:
		print("chosen talent: ", Globals.get_talent_name(talent_index))
	change_state(GameState.PLAY)

func on_exit_game():
	Settings.save_settings()
	get_tree().quit(0)

func instance_character_at(scene: PackedScene, pos: Vector2) -> Node:
	var inst = scene.instance()
	inst.position = pos
	$Characters.add_child(inst, true)
	inst.add_to_group("enemies")
	if scene == vomiting_kid_scene:
		inst.connect("vomit", self, "_on_vomit")
	return inst

func get_random_kid() -> PackedScene:
	var rand = randf()
	if rand < 0.20:
		return spitting_kid_scene
	elif rand < 0.52:
		return stick_kid_scene
	elif rand < 0.74:
		return booger_kid_scene
	elif rand < 0.89:
		return crying_kid_scene
	else:
		return vomiting_kid_scene

#
# Stuff to do when the background has been instanced but before the game
# actually starts: determine where the alien will appear, put the camera there,
# and populate the scene with bad guys.
#
func prepare_game():

	# position the camera where the alien will appear

	var pos = background.get_alien_starting_point()
	$Camera.position = pos

	# add teacher and some kids, on camera (or not far off camera...)

	var window_size = _get_window_size() * 1.5
	var bbox = Rect2(pos - window_size / 2.0, window_size)

	var positions = background.get_spawning_points(1 + kids_on_camera, bbox)
	teacher = instance_character_at(teacher_scene, positions[0])
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

	# choose a talent at random if the user chose RANDOM

	if chosen_talent != Globals.Talent.RANDOM:
		actual_talent = chosen_talent
	elif unlock_all_talents:
		actual_talent = Globals.get_random_talent(100)
	else:
		actual_talent = Globals.get_random_talent(Settings.get_best_score())

	if chosen_talent == Globals.Talent.RANDOM and Globals.VERBOSE:
		print("random talent: ", Globals.get_talent_name(actual_talent))

	# instance the alien and position him in front of the camera, initially

	alien = alien_scene.instance()
	alien.position = $Camera.position
	alien.connect("dead", self, "_on_alien_dead", [], CONNECT_ONESHOT)
	$Characters.add_child(alien)

	match actual_talent:
		Globals.Talent.DODGE:
			alien.set_hit_collider_size(true)
		Globals.Talent.SPEED:
			alien.set_run_cycle_speed(SPEED_run_cycle_speed)
			alien.set_run_speed(SPEED_run_speed)
		Globals.Talent.TELEPORT:
			alien.connect("teleport", self, "teleport")
		Globals.Talent.SECOND_LIFE:
			alien.connect("second_life", self, "_on_second_life")
		Globals.Talent.GHOST:
			alien.connect("ghost_done", self, "_on_ghost_done")

	alien.beam_down(actual_talent)

	# from now on, the camera follows the alien's movements

	set_process(true)

	# stop menu music, start background noise and intro music (game music
	# starts when intro music finishes)

	$Audio/Menu_Music.stop()
	$Audio/Background_Sound.play()
	$Audio/Intro_Music.play()

	# wait for the beam down animation to finish before starting the overlay
	# animation, which will eventually make it impossible to see, spawning
	# enemies and counting down

	yield(alien, "beam_down_finished")
	if not block_overlay_animation:
		overlay.start_animation()
		$Shutdown_Timer.start()
	$Enemy_Timer.start(spawn_first_time)
	$ScoreTracker.start_game()

	# other random sounds

	if Settings.get_best_score() >= 60:
		$Audio/Bell_Timer.start(rand_range(15, 25))
	$Audio/Ambulance_Timer.start(rand_range(30, 50))

func _on_Intro_Music_finished():
	if state == GameState.PLAY:
		$Audio/Game_Music.play()

func _on_Enemy_Timer_timeout():
	if state != GameState.PLAY:
		return

	# find a spawning point off-camera

	var window_size = _get_window_size() * 1.5
	var bbox = Rect2($Camera.position - window_size / 2.0, window_size)
	var pos = background.get_spawning_point(null, bbox)

	# spawn the enemy and restart the timer

	var enemy = instance_character_at(get_random_kid(), pos)
	if $Talent_Overlays/Bullet_Time.is_running():
		enemy.set_time_scale(BULLET_TIME_slowdown)
	if alien.is_ghost_running():
		enemy.add_collision_exception_with(alien)
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
	
	$Audio/Background_Sound.stop()
	$Audio/Intro_Music.stop()
	$Audio/Game_Music.stop()
	$Audio/Bell_Timer.stop()
	$Audio/Bell.stop()
	$Audio/Ambulance_Timer.stop()
	$Audio/Ambulance.stop()
	$Talents/Talent_Timer.stop()
	$Enemy_Timer.stop()
	$Shutdown_Timer.stop()
	$Shutdown_Overlay.hide()
	$Shutdown_Overlay.reset_animation()
	
	match actual_talent:
		Globals.Talent.DASH:
			stop_dash()
		Globals.Talent.FORCE_FIELD:
			alien.stop_force_field()
		Globals.Talent.TIME_STOP:
			stop_time_stop()
		Globals.Talent.MIRROR_IMAGE:
			stop_mirror_images()
		Globals.Talent.INVISIBLE:
			stop_invisible()
		Globals.Talent.SHIELD:
			alien.stop_shield()
		Globals.Talent.SECOND_LIFE:
			stop_second_life()
		Globals.Talent.TECHNICIAN:
			techniker_used = false
		Globals.Talent.BULLET_TIME:
			stop_bullet_time()
		Globals.Talent.GHOST:
			alien.stop_ghost()
	
	overlay.reset_animation()
	
	alien.queue_free()
	alien = null	
	teacher = null
	get_tree().call_group("enemies", "free")

func start_teleport():
	alien.start_teleport()
	alien.start_cooldown(TELEPORT_cooldown)

func teleport():
	alien.position = background.get_teleportation_point()

func start_dash():
	alien.start_cooldown(DASH_cooldown)
	alien.set_run_cycle_speed(DASH_run_cycle_speed)
	alien.set_run_speed(DASH_run_speed)
	$Talents/Dash.start(DASH_duration)

func update_dash_trail():
	$Talents/Dash.add_point_to_trail(alien.position)

func _on_dash_done():
	alien.set_run_cycle_speed(1)
	alien.set_run_speed(1)

func stop_dash():
	$Talents/Dash.stop()

func start_explosion():
	alien.start_cooldown(EXPLOSION_cooldown)
	alien.start_explosion()
	$Camera_Shake.play("shake")
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy == teacher:
			continue
		var dist2 = Globals.get_persp_dist_squared(
			enemy.position, alien.position)
		if dist2 < EXPLOSION_radius * EXPLOSION_radius:
			enemy.repulse(
				alien.position, EXPLOSION_distance, EXPLOSION_duration)

func start_freeze():
	alien.start_cooldown(FREEZE_cooldown)
	alien.start_freeze()
	for enemy in get_tree().get_nodes_in_group("enemies"):
		var dist2 = Globals.get_persp_dist_squared(
			enemy.position, alien.position)
		if dist2 < FREEZE_radius * FREEZE_radius:
			enemy.freeze()
			$Talents/Talent_Timer.connect(
				"timeout", enemy, "unfreeze", [], CONNECT_ONESHOT)
	$Talents/Talent_Timer.start(FREEZE_duration)

func start_shield():
	alien.start_cooldown(SHIELD_cooldown)
	alien.start_shield(SHIELD_duration)

func start_force_field():
	alien.start_cooldown(FORCE_FIELD_cooldown)
	alien.start_force_field(FORCE_FIELD_duration)

func start_time_stop():
	alien.start_cooldown(TIME_STOP_cooldown)
	$Talent_Overlays/Time_Stop.start(TIME_STOP_duration)
	$Enemy_Timer.set_paused(true)
	get_tree().call_group("enemies", "stop_time")

func _on_time_stop_done():
	$Enemy_Timer.set_paused(false)
	get_tree().call_group("enemies", "restart_time")

func stop_time_stop():
	$Talent_Overlays/Time_Stop.stop()
	$Enemy_Timer.set_paused(false)

func start_mirror_images():
	alien.start_cooldown(MIRROR_IMAGE_cooldown)
	$Talent_Overlays/Mirror_Images/AnimationPlayer.play("mirror_images")
	for dir in [ Vector2(-1,-1), Vector2(1,-1), Vector2(0,1) ]:
		var offset = dir.normalized() * 10
		var mirror = alien_scene.instance()
		alien.get_parent().add_child_below_node(alien, mirror)
		mirror.add_to_group("mirror_images");
		mirror.start_mirror(MIRROR_IMAGE_duration, alien.position + offset, dir)
		mirror.show()

func stop_mirror_images():
	$Talent_Overlays/Mirror_Images/AnimationPlayer.play("RESET")
	get_tree().call_group("mirror_images", "free")

func start_invisible():
	alien.start_cooldown(INVISIBLE_cooldown)
	alien.start_invisible(INVISIBLE_duration)

func stop_invisible():
	alien.stop_invisible()

func _on_second_life():
	$Talent_Overlays/Second_Life/AnimationPlayer.play("second_life")

func stop_second_life():
	$Talent_Overlays/Second_Life/AnimationPlayer.play("RESET")

func start_techniker():
	if techniker_used or $Shutdown_Overlay.visible:
		return
	techniker_used = true
	if not block_overlay_animation:
		$Shutdown_Timer.start()
	$Talent_Overlays/Techniker/AnimationPlayer.play("techniker")
	yield($Talent_Overlays/Techniker/AnimationPlayer, "animation_finished")
	overlay.rewind_animation()

func start_bullet_time():
	alien.start_cooldown(BULLET_TIME_cooldown)
	$Talent_Overlays/Bullet_Time.start(BULLET_TIME_duration)
	get_tree().call_group("enemies", "set_time_scale", BULLET_TIME_slowdown)

func _on_bullet_time_done():
	get_tree().call_group("enemies", "set_time_scale", 1)

func stop_bullet_time():
	$Talent_Overlays/Bullet_Time.stop()

func start_ghost():
	alien.start_cooldown(GHOST_cooldown)
	alien.start_ghost()
	get_tree().call_group("enemies", "add_collision_exception_with", alien)

func _on_ghost_done():
	get_tree().call_group("enemies", "remove_collision_exception_with", alien)

func _on_vomit(pos: Vector2):
	yield(get_tree().create_timer(2.0 / Globals.FPS), "timeout")
	# in case the game ends just after the kid vomits...
	if is_instance_valid(background):
		var puddle = vomit_scene.instance()
		puddle.position = pos
		background.add_child(puddle)

func _on_alien_dead():
	stop_game()
	change_state(GameState.DEATH)

func _on_Bell_Timer_timeout():
	$Audio/Bell.play()
	$Audio/Bell_Timer.start(rand_range(15, 25))

func _on_Ambulance_Timer_timeout():
	$Audio/Ambulance.play()

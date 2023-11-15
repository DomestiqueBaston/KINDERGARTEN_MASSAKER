extends Node2D

const SceneDash = preload("res://SCENES/TMP/SceneDASH.tscn")
const Invisible = preload("res://SCENES/TMP/SceneINVISIBLE.tscn")
const Bouclier = preload("res://SCENES/TMP/SceneSHIELD.tscn")
const Force_Field = preload("res://SCENES/TMP/SceneFORCE_FIELD.tscn")
const Teleport = preload("res://SCENES/TMP/SceneTELEPORT.tscn")
const Mirror_Images = preload("res://SCENES/TMP/SceneMIRROR_IMAGES.tscn")
const Freezing = preload("res://SCENES/TMP/SceneFREEZING.tscn")
const Time_Stop = preload("res://SCENES/TMP/SceneTIME_STOP.tscn")
const Explosion = preload("res://SCENES/TMP/SceneEXPLOSION.tscn")
const Techniker = preload("res://SCENES/TMP/SceneTECHNIKER.tscn")
const SceneDeath = preload("res://SCENES/SCREENS/Death.tscn")
const Dialogue = preload("res://SCENES/SCREENS/Dialogue.tscn")

var menu = preload("res://SCENES/SCREENS/Menu.tscn")
var options = preload("res://SCENES/SCREENS/Options.tscn")
var credits = preload("res://SCENES/SCREENS/Credits.tscn")
var dialogue = preload("res://SCENES/SCREENS/Dialogue.tscn")

var credits_seen = false

enum GameState {
	TITLE,
	MENU,
	OPTIONS,
	CREDITS,
	DIALOGUE
}

var state = GameState.TITLE

func _ready():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var overlay_path
	match rng.randi_range(1, 3):
		1:
			overlay_path = "res://SCENES/OVERLAYS/Game_Overlay_1.tscn"
		2:
			overlay_path = "res://SCENES/OVERLAYS/Game_Overlay_2.tscn"
		3:
			overlay_path = "res://SCENES/OVERLAYS/Game_Overlay_3.tscn"
	var overlay_scene = load(overlay_path)
	$PAPA_Game_Overlay.add_child(overlay_scene.instance())

func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("full_screen"):
		OS.window_fullscreen = !OS.window_fullscreen
		get_tree().set_input_as_handled()

func _unhandled_key_input(event: InputEventKey):
	if state != GameState.MENU and Autoload.event_is_key_press(event):
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
			child.connect("show_options", self, "on_show_options")
			child.connect("show_credits", self, "on_show_credits")
			child.connect("exit_game", self, "on_exit_game")
			child.connect("show_dialogue", self, "on_show_dialogue")
		GameState.OPTIONS:
			child = options.instance()
		GameState.CREDITS:
			child = credits.instance()
			credits_seen = true
		GameState.DIALOGUE:
			child = dialogue.instance()
	$Active_Scene.add_child(child)
	state = next_state

func _on_Transition_Overlay_transition_finished():
	$Transition_Overlay.hide()

func on_start_game():
	pass

func on_show_options():
	change_state(GameState.OPTIONS)

func on_show_credits():
	change_state(GameState.CREDITS)

func on_show_dialogue():
	change_state(GameState.DIALOGUE)

func on_exit_game():
	get_tree().quit(0)

func _process_Ferdi(_delta):
	if Input.is_action_just_pressed("DIALOGUE") and not Autoload.transition_signal:
		if Autoload.scene_changed == true:
			Autoload.choice = 10
			to_DIALOGUE()
	if Input.is_action_just_pressed("DER_TECHNIKER") and not Autoload.transition_signal:
		if Autoload.scene_changed == true:
			Autoload.choice = 9
			to_DER_TECHNIKER()
	if Input.is_action_just_pressed("EXPLOSION") and not Autoload.transition_signal:
		if Autoload.scene_changed == true:
			Autoload.choice = 8
			to_EXPLOSION()
	if Input.is_action_just_pressed("TIME_STOP") and not Autoload.transition_signal:
		if Autoload.scene_changed == true:
			Autoload.choice = 7
			to_TIME_STOP()
	if Input.is_action_just_pressed("FREEZING") and not Autoload.transition_signal:
		if Autoload.scene_changed == true:
			Autoload.choice = 6
			to_FREEZING()
	if Input.is_action_just_pressed("MIRROR_IMAGES") and not Autoload.transition_signal:
		if Autoload.scene_changed == true:
			Autoload.choice = 5
			to_MIRROR_IMAGES()
	if Input.is_action_just_pressed("TELEPORT") and not Autoload.transition_signal:
		if Autoload.scene_changed == true:
			Autoload.choice = 4
			to_TELEPORT()
	if Input.is_action_just_pressed("FORCE_FIELD") and not Autoload.transition_signal:
		if Autoload.scene_changed == true:
			Autoload.choice = 3
			to_FORCE_FIELD()
	if Input.is_action_just_pressed("SHIELD") and not Autoload.transition_signal:
		if Autoload.scene_changed == true:
			Autoload.choice = 2
			to_BOUCLIER()
	if Input.is_action_just_pressed("INVISIBLE") and not Autoload.transition_signal:
		if Autoload.scene_changed == true:
			Autoload.choice = 1
			to_INVISIBLE()
	if Input.is_action_just_pressed("DASH") and not Autoload.transition_signal:
		if Autoload.scene_changed == true:
			Autoload.choice = 0
			to_DASH()
	if Autoload.time_to_die:
		if Autoload.scene_changed == true:
			to_scene2()
	if Input.is_action_just_pressed("ui_cancel") and Autoload.transition_signal:
		finally_no()
	if Autoload.transition_signal:
		$Transition_Overlay.hide()
	if Autoload.restart_game:
		$Transition_Overlay.visible = true
		one_more_time()

func one_more_time():
	Autoload.scene_changed = false
	Autoload.transition_signal = false
	Autoload.restart_game = false
	Autoload.time_before_death = 50.0
	Autoload.time_to_die = false
	Autoload.elapsed_time = 0.0
#	var _useless = get_tree().reload_current_scene()
	$Transition_Overlay.visible = true
	$Transition_Overlay/Sprite.take_screenshot()
	$Active_Scene.get_child(0).queue_free()
	if Autoload.choice == 0:
		$Active_Scene.add_child(SceneDash.instance())
	if Autoload.choice == 1:
		$Active_Scene.add_child(Invisible.instance())
	if Autoload.choice == 2:
		$Active_Scene.add_child(Bouclier.instance())
	if Autoload.choice == 3:
		$Active_Scene.add_child(Force_Field.instance())
	if Autoload.choice == 4:
		$Active_Scene.add_child(Teleport.instance())
	if Autoload.choice == 5:
		$Active_Scene.add_child(Mirror_Images.instance())
	if Autoload.choice == 6:
		$Active_Scene.add_child(Freezing.instance())
	if Autoload.choice == 7:
		$Active_Scene.add_child(Time_Stop.instance())
	if Autoload.choice == 8:
		$Active_Scene.add_child(Explosion.instance())
	if Autoload.choice == 9:
		$Active_Scene.add_child(Techniker.instance())
	if Autoload.choice == 10:
		$Active_Scene.add_child(Dialogue.instance())

func finally_no():
	Autoload.scene_changed = true
	Autoload.transition_signal = false
	Autoload.restart_game = false
	Autoload.time_before_death = 50.0
	Autoload.time_to_die = false
	Autoload.elapsed_time = 0.0
	var _useless = get_tree().reload_current_scene()

func to_DIALOGUE():
	Autoload.scene_changed = false
	$Transition_Overlay/Sprite.take_screenshot()
	$Active_Scene.get_child(0).queue_free()
	$Active_Scene.add_child(Dialogue.instance())
	
func to_DER_TECHNIKER():
	Autoload.scene_changed = false
	Autoload.time_before_death = 50.0
	Autoload.time_to_die = false
	$Transition_Overlay/Sprite.take_screenshot()
	$Active_Scene.get_child(0).queue_free()
	$Active_Scene.add_child(Techniker.instance())

func to_DASH():
	Autoload.scene_changed = false
	Autoload.time_before_death = 50.0
	Autoload.time_to_die = false
	$Transition_Overlay/Sprite.take_screenshot()
	$Active_Scene.get_child(0).queue_free()
	$Active_Scene.add_child(SceneDash.instance())

func to_EXPLOSION():
	Autoload.scene_changed = false
	Autoload.time_before_death = 50.0
	Autoload.time_to_die = false
	$Transition_Overlay/Sprite.take_screenshot()
	$Active_Scene.get_child(0).queue_free()
	$Active_Scene.add_child(Explosion.instance())

func to_TIME_STOP():
	Autoload.scene_changed = false
	Autoload.time_before_death = 50.0
	Autoload.time_to_die = false
	$Transition_Overlay/Sprite.take_screenshot()
	$Active_Scene.get_child(0).queue_free()
	$Active_Scene.add_child(Time_Stop.instance())

func to_FREEZING():
	Autoload.scene_changed = false
	Autoload.time_before_death = 50.0
	Autoload.time_to_die = false
	$Transition_Overlay/Sprite.take_screenshot()
	$Active_Scene.get_child(0).queue_free()
	$Active_Scene.add_child(Freezing.instance())

func to_MIRROR_IMAGES():
	Autoload.scene_changed = false
	Autoload.time_before_death = 50.0
	Autoload.time_to_die = false
	$Transition_Overlay/Sprite.take_screenshot()
	$Active_Scene.get_child(0).queue_free()
	$Active_Scene.add_child(Mirror_Images.instance())

func to_TELEPORT():
	Autoload.scene_changed = false
	Autoload.time_before_death = 50.0
	Autoload.time_to_die = false
	$Transition_Overlay/Sprite.take_screenshot()
	$Active_Scene.get_child(0).queue_free()
	$Active_Scene.add_child(Teleport.instance())

func to_FORCE_FIELD():
	Autoload.scene_changed = false
	Autoload.time_before_death = 50.0
	Autoload.time_to_die = false
	$Transition_Overlay/Sprite.take_screenshot()
	$Active_Scene.get_child(0).queue_free()
	$Active_Scene.add_child(Force_Field.instance())

func to_BOUCLIER():
	Autoload.scene_changed = false
	Autoload.time_before_death = 50.0
	Autoload.time_to_die = false
	$Transition_Overlay/Sprite.take_screenshot()
	$Active_Scene.get_child(0).queue_free()
	$Active_Scene.add_child(Bouclier.instance())

func to_INVISIBLE():
	Autoload.scene_changed = false
	Autoload.time_before_death = 50.0
	Autoload.time_to_die = false
	$Transition_Overlay/Sprite.take_screenshot()
	$Active_Scene.get_child(0).queue_free()
	$Active_Scene.add_child(Invisible.instance())
	
func to_scene2():
	Autoload.scene_changed = false
	$Active_Scene.get_child(0).queue_free()
	$Active_Scene.add_child(SceneDeath.instance())
	Autoload.transition_signal = true

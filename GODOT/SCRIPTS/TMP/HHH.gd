extends Node2D


const SceneDash = preload("res://SCENES/TMP/SceneDASH.tscn")
const Invisible = preload("res://SCENES/TMP/SceneINVISIBLE.tscn")
const Bouclier = preload("res://SCENES/TMP/SceneSHIELD.tscn")
const Force_Field = preload("res://SCENES/TMP/SceneFORCE_FIELD.tscn")
const Teleport = preload("res://SCENES/TMP/SceneTELEPORT.tscn")
const Schockwave = preload("res://SCENES/TMP/SceneSHOCKWAVE.tscn")
const Freezing = preload("res://SCENES/TMP/SceneFREEZING.tscn")
const Time_Stop = preload("res://SCENES/TMP/SceneTIME_STOP.tscn")
const Explosion = preload("res://SCENES/TMP/SceneEXPLOSION.tscn")

const SceneDeath = preload("res://SCENES/SCREENS/Death.tscn")


func _process(_delta):
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
	if Input.is_action_just_pressed("SCHOCKWAVE") and not Autoload.transition_signal:
		if Autoload.scene_changed == true:
			Autoload.choice = 5
			to_SCHOCKWAVE()
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
			to_scene1()
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
		$Active_Scene.add_child(Schockwave.instance())
	if Autoload.choice == 6:
		$Active_Scene.add_child(Freezing.instance())
	if Autoload.choice == 7:
		$Active_Scene.add_child(Time_Stop.instance())
	if Autoload.choice == 8:
		$Active_Scene.add_child(Explosion.instance())

func finally_no():
	Autoload.scene_changed = true
	Autoload.transition_signal = false
	Autoload.restart_game = false
	Autoload.time_before_death = 50.0
	Autoload.time_to_die = false
	Autoload.elapsed_time = 0.0
	var _useless = get_tree().reload_current_scene()

func to_scene1():
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

func to_SCHOCKWAVE():
	Autoload.scene_changed = false
	Autoload.time_before_death = 50.0
	Autoload.time_to_die = false
	$Transition_Overlay/Sprite.take_screenshot()
	$Active_Scene.get_child(0).queue_free()
	$Active_Scene.add_child(Schockwave.instance())

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

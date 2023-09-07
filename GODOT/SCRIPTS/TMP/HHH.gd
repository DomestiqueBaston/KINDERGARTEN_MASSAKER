extends Node2D


const SceneTwo = preload("res://SCENES/TMP/SceneTEST.tscn")
const SceneDeath = preload("res://SCENES/SCREENS/Death.tscn")


func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel") and not Autoload.transition_signal:
		if Autoload.scene_changed == true:
			to_scene1()
	if Autoload.time_to_die:
		if Autoload.scene_changed == true:
			to_scene2()
	if Input.is_action_just_pressed("ui_cancel") and Autoload.transition_signal:
		one_more_time()
	if Autoload.transition_signal:
		$Transition_Overlay.hide()
	if Autoload.restart_game:
		$Transition_Overlay.visible = true
		one_more_time()
		
func one_more_time():
	Autoload.scene_changed = false
	Autoload.transition_signal = false
	Autoload.restart_game = false
	Autoload.time_before_death = 25.0
	Autoload.time_to_die = false
	Autoload.elapsed_time = 0.0
	$Transition_Overlay/Sprite.take_screenshot()
	$Active_Scene.get_child(0).queue_free()
	$Active_Scene.add_child(SceneTwo.instance())

func to_scene1():
	Autoload.scene_changed = false
	Autoload.time_before_death = 25.0
	Autoload.time_to_die = false
	$Transition_Overlay/Sprite.take_screenshot()
	$Active_Scene.get_child(0).queue_free()
	$Active_Scene.add_child(SceneTwo.instance())
	
func to_scene2():
	Autoload.scene_changed = false
	$Active_Scene.get_child(0).queue_free()
	$Active_Scene.add_child(SceneDeath.instance())
	Autoload.transition_signal = false

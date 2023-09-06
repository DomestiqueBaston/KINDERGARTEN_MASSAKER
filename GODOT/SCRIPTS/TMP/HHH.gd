extends Node2D


const SceneTwo = preload("res://SCENES/TMP/SceneTEST.tscn")
const SceneDeath = preload("res://SCENES/SCREENS/Death.tscn")


func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel") and not Autoload.transition_signal:
		Autoload.time_before_death = 25.0
		Autoload.time_to_die = false
		$Transition_Overlay/Sprite.take_screenshot()
		$Active_Scene.get_child(0).queue_free()
		yield($Active_Scene.get_child(0), "tree_exited")
		$Active_Scene.add_child(SceneTwo.instance())
	if Input.is_action_just_pressed("ui_cancel") and Autoload.transition_signal:
		Autoload.transition_signal = false
		var _useless = get_tree().reload_current_scene() #"var _useless = " to silent Godot
	if Autoload.transition_signal:
		$Transition_Overlay.hide()
	if Autoload.time_to_die:
		$Active_Scene.get_child(0).queue_free()
		yield($Active_Scene.get_child(0), "tree_exited")
		$Active_Scene.add_child(SceneDeath.instance())
		Autoload.transition_signal = false

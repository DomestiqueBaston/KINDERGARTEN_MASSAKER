extends Node2D


const SceneTwo = preload("res://SCENES/TMP/SceneTEST.tscn")

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel") and not Autoload.transition_signal:
		$Transition_Overlay/Sprite.take_screenshot()
		$Active_Scene.get_child(0).queue_free()
		$Active_Scene.add_child(SceneTwo.instance())

	if Autoload.transition_signal == true:
		$Transition_Overlay.hide()


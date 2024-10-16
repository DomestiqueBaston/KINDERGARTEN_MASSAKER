extends Node2D

func is_running() -> bool:
	return $Force_Field.visible

func start(duration):
	$Force_Field_Timer.start(duration - $FX_OFF.stream.get_length())
	$AnimationPlayer.play("force_field")
	$Force_Field.show()
	$FX_ON.play()
	yield($FX_ON, "finished")
	$FX.play()

func _on_Force_Field_Timer_timeout():
	$FX.stop()
	$FX_OFF.play()
	$Force_Field.hide()

func stop():
	$Force_Field_Timer.stop()
	$AnimationPlayer.play("RESET")
	$FX.stop()
	$FX_ON.stop()
	$FX_OFF.stop()
	$Force_Field.hide()

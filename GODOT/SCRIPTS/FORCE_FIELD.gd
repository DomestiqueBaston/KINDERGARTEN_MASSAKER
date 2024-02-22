extends Node2D

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

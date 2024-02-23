extends Node2D

func start(duration):
	$Shield_Timer.start(duration - $FX_OFF.stream.get_length())
	$AnimationPlayer.play("shield")
	$Shield.show()
	$FX_ON.play()
	yield($FX_ON, "finished")
	$FX.play()

func _on_Shield_Timer_timeout():
	$FX.stop()
	$FX_OFF.play()
	$Shield.hide()

func stop():
	$Shield_Timer.stop()
	$AnimationPlayer.play("RESET")
	$FX.stop()
	$FX_ON.stop()
	$FX_OFF.stop()
	$Shield.hide()

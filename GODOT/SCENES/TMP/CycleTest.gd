extends Node2D

var speed := 1.0

func _ready():
	$CyclePlayer.play("Run")

func _unhandled_key_input(event: InputEventKey):
	if event.pressed:
		match event.scancode:
			KEY_I:
				$CyclePlayer.play("Idle")
			KEY_R:
				$CyclePlayer.play("Run")
			KEY_S:
				$CyclePlayer.play("Scratching", true)
			KEY_LEFT:
				$CyclePlayer.set_direction(CyclePlayer.Dir.W)
			KEY_RIGHT:
				$CyclePlayer.set_direction(CyclePlayer.Dir.E)
			KEY_UP:
				$CyclePlayer.set_direction(CyclePlayer.Dir.N)
			KEY_DOWN:
				$CyclePlayer.set_direction(CyclePlayer.Dir.S)
			KEY_EQUAL:
				speed *= 2
				$CyclePlayer.set_speed(speed)
			KEY_MINUS:
				speed /= 2
				$CyclePlayer.set_speed(speed)
			KEY_V:
				speed *= -1
				$CyclePlayer.set_speed(speed)
			KEY_ESCAPE:
				get_tree().quit(0)

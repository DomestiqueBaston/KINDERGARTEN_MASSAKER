extends KinematicBody2D


var speed = 175
var SPEED = Vector2(speed, speed / 1.5)
var velocity = Vector2()

func get_input():
	velocity = Vector2()
	if Input.is_action_pressed("ui_down"):
		velocity.y += 0.75
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 0.75
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1.0
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1.0
	velocity = velocity.normalized() * SPEED
#	print(velocity)
	if Input.is_action_pressed('full_screen'):
		OS.window_fullscreen = !OS.window_fullscreen
		return true
	return false


func _physics_process(_delta):
# warning-ignore:return_value_discarded
	get_input()
	velocity = move_and_slide(velocity)
	

extends KinematicBody2D


var speed = 175
var SPEED = Vector2(speed, speed / 1.5)
var velocity = Vector2()

func get_input():
	velocity = Vector2()
	if Input.is_action_pressed("ui_down"):
		velocity.y += .75
	if Input.is_action_pressed("ui_up"):
		velocity.y -= .75
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
	velocity = velocity.normalized() * SPEED
#	print(velocity)


func _physics_process(_delta):
# warning-ignore:return_value_discarded
	get_input()
	velocity = move_and_slide(velocity)
	

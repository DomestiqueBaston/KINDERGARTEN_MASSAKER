extends KinematicBody2D

var speed = 175
var velocity = Vector2()

func get_input():
	velocity = Vector2()
	if Input.is_action_pressed("ui_down"):
		velocity.y += 1
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 1
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
	velocity = velocity.normalized() * speed
	
func _physics_process(_delta):
# warning-ignore:return_value_discarded
	get_input()
	velocity = move_and_slide(velocity)
	

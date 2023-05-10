extends KinematicBody2D

var speed = 200
var velocity = Vector2()

func get_input():
	velocity = Vector2()
	if Input.is_action_pressed("ui_down"):
		velocity.y += speed
	if Input.is_action_pressed("ui_up"):
		velocity.y -= speed
	if Input.is_action_pressed("ui_left"):
		velocity.x -= speed
	if Input.is_action_pressed("ui_right"):
		velocity.x += speed
	#velocity = velocity.normalized()
	
func _physics_process(_delta):
# warning-ignore:return_value_discarded
	get_input()
	velocity = move_and_slide(velocity)
	

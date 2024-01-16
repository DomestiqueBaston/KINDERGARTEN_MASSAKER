#	Everything's temporary here, to test the AnimationTree.

extends KinematicBody2D


export(int) var speed = 125

func _physics_process(_delta):
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1.0
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1.0
	if Input.is_action_pressed("ui_down"):
		velocity.y += 1
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 1
	
	if velocity == Vector2.ZERO:
		$AnimationTree.get("parameters/playback").travel("Check")
	else:
		$AnimationTree.get("parameters/playback").travel("Run")
		$AnimationTree.set("parameters/Check/blend_position", velocity)
		$AnimationTree.set("parameters/Run/blend_position", velocity)
		velocity = velocity.normalized()
		velocity.y *= .75 #Not an ideal solution but I did my best...
		var _ignore_collision = move_and_slide(velocity * speed)

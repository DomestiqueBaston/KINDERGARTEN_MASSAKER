extends KinematicBody2D

# speed of movement in pixels/second
export var speed = Vector2(125, 62.5)

var anim_tree
var state_machine
var direction = Vector2.ZERO

func _ready():
	anim_tree = $AnimationTree
	state_machine = anim_tree["parameters/playback"]

func _physics_process(delta):
	var dir = Vector2.ZERO
	if Input.is_action_pressed("ui_left"):
		dir.x -= 1
	if Input.is_action_pressed("ui_right"):
		dir.x += 1
	if Input.is_action_pressed("ui_up"):
		dir.y -= 1
	if Input.is_action_pressed("ui_down"):
		dir.y += 1

	if dir == Vector2.ZERO:
		state_machine.travel("Idle")
	else:
		direction = dir.normalized()
		anim_tree["parameters/Idle/blend_position"] = direction
		anim_tree["parameters/Run/blend_position"] = direction
		state_machine.travel("Run")
		var _collision = move_and_collide(direction * speed * delta)

extends KinematicBody2D


var speed = 175
var SPEED = Vector2(speed, speed / 1.5)
var velocity = Vector2()


func _ready():
	set_physics_process(false)

func _physics_process(_delta):
# warning-ignore:return_value_discarded
	get_input()
	velocity = move_and_slide(velocity)

func _process(delta):
	Autoload.elapsed_time += delta
#	Just to demo the outline shader (without fancy effects)
#	as it won't be used like that in the game.
	$"CHARACTERS/The Alien (with OUTLINE shader)".material.set_shader_param("cooldown", Color(0.0, 0.0, 0.0, 1.0))
#	Collision test
	for i in range(get_slide_count()):
		var _collision = get_slide_collision(i)
		$"CHARACTERS/The Alien (with OUTLINE shader)".material.set_shader_param("cooldown", Color(1.0, 0.0, 0.0, 1.0))
		Autoload.time_before_death -= 1.0
	if Autoload.time_before_death <= 0:
		Autoload.time_to_die = true
		Autoload.scene_changed = true

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


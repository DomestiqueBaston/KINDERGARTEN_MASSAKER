extends KinematicBody2D


var speed = 175
var SPEED = Vector2(speed, speed / 1.5)
var dash_speed = 1
var velocity = Vector2()

var cooldown_ready = true


func _ready():
	set_physics_process(false)
	$"PLAYER/The Alien (with OUTLINE shader)".material.set_shader_param("cooldown", Color(0.0, 0.0, 0.0, 1.0))

func _physics_process(_delta):
# warning-ignore:return_value_discarded
	get_input()
	velocity = move_and_slide(velocity)

func _process(delta):
	Autoload.elapsed_time += delta
	
#	Collision test
	for i in range(get_slide_count()):
		var _collision = get_slide_collision(i)
		Autoload.time_before_death -= 1.0
	if Autoload.time_before_death <= 0:
		Autoload.time_to_die = true
		Autoload.scene_changed = true

func get_input():
	velocity = Vector2()
	if Input.is_action_just_pressed("ui_a"):
		start_dash_timer()
	if Input.is_action_pressed("ui_down"):
		velocity.y += 0.75
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 0.75
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1.0
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1.0
	velocity = velocity.normalized() * (SPEED * dash_speed)

func start_dash_timer():
	if cooldown_ready:
		if $PLAYER/Dash_Trail/Dash_Timer.is_stopped():
			$PLAYER/FX.play(0.0)
			$PLAYER/Dash_Trail/Cooldown_Timer.start()
			$PLAYER/Dash_Trail/Dash_Timer.start()
			$"PLAYER/The Alien (with OUTLINE shader)".material.set_shader_param("cooldown", Color(0.71, 0.21, 0.27, 1.0))
			cooldown_ready = false
			dash_speed = 5
			$PLAYER/Dash_Trail.visible = true

func _on_Dash_Timer_timeout():
	dash_speed = 1
	$PLAYER/Dash_Trail.hide()
	$PLAYER/Dash_Trail.clear_points()	#hide()

func _on_Cooldown_Timer_timeout():
	cooldown_ready = true
	$"PLAYER/The Alien (with OUTLINE shader)".material.set_shader_param("cooldown", Color(0.0, 0.0, 0.0, 1.0))

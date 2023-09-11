extends KinematicBody2D


var speed = 175
var SPEED = Vector2(speed, speed / 1.5)
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
		start_timers()
	if Input.is_action_pressed("ui_down"):
		velocity.y += 0.75
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 0.75
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1.0
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1.0
	velocity = velocity.normalized() * (SPEED)

func start_timers():
	if cooldown_ready:
		$PLAYER/Cooldown_Timer.start()
		$PLAYER/Freezing_Front.visible = true
		$PLAYER/Freezing_Back.visible = true
		$PLAYER/AnimationPlayer.play("freezing")
		$"PLAYER/The Alien (with OUTLINE shader)".material.set_shader_param("cooldown", Color(0.71, 0.21, 0.27, 1.0))
		cooldown_ready = false
		yield($PLAYER/AnimationPlayer, "animation_finished")
		$PLAYER/Freezing_Front.visible = false
		$PLAYER/Freezing_Back.visible = false

func _on_Cooldown_Timer_timeout():
#	Outline redevient noir !
	$"PLAYER/The Alien (with OUTLINE shader)".material.set_shader_param("cooldown", Color(0.0, 0.0, 0.0, 1.0))
	cooldown_ready = true

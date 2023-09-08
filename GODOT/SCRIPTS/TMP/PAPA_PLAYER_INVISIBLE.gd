extends KinematicBody2D


const outline = preload("res://SHADERS/Outline.shader")
const outline_invisible = preload("res://SHADERS/Outline_Invisible.shader")

var speed = 175
var SPEED = Vector2(speed, speed / 1.5)
var velocity = Vector2()
var cooldown_ready = true


func _ready():
	set_physics_process(false)

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
		$PLAYER/FX_ON.play(0.0)
#		Si le timer est prêt :
		$PLAYER/Invisible_Timer.start()
		$PLAYER/Cooldown_Timer.start()
#		Devient transparent et l'Outline devient rouge
		$"PLAYER/The Alien (with OUTLINE shader)".material.shader = outline_invisible
		$"PLAYER/The Alien (with OUTLINE shader)".material.set_shader_param("cooldown", Color(0.71, 0.21, 0.27, 1.0))
#		$"PLAYER/The Alien (with OUTLINE shader)".self_modulate.a = 0.5
		$"PLAYER/Shadow".self_modulate.a = 0.35
		cooldown_ready = false


func _on_Invisible_Timer_timeout():
	$PLAYER/FX_OFF.play(0.0)
#	redevient visible !
#	$"PLAYER/The Alien (with OUTLINE shader)".self_modulate.a = 1.0
	$"PLAYER/Shadow".self_modulate.a = 1.0
	$"PLAYER/The Alien (with OUTLINE shader)".material.shader = outline
	$"PLAYER/The Alien (with OUTLINE shader)".material.set_shader_param("cooldown", Color(0.71, 0.21, 0.27, 1.0))

func _on_Cooldown_Timer_timeout():
#	Outline redevient noir !
	$"PLAYER/The Alien (with OUTLINE shader)".material.set_shader_param("cooldown", Color(0.0, 0.0, 0.0, 1.0))
	cooldown_ready = true

extends KinematicBody2D


var speed = 175
var SPEED = Vector2(speed, speed / 1.5)
var velocity = Vector2()
var cooldown_ready = true

var bad_teleportation = false


#var start_position = Vector2(720,405)
var teleport_position = Vector2()

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
	if bad_teleportation:
		self.position = Vector2(720,405)
		bad_teleportation = false

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
		$"PLAYER/The Alien (with OUTLINE shader)".material.set_shader_param("cooldown", Color(0.71, 0.21, 0.27, 1.0))
		$PLAYER/AnimationPlayer.play("Teleport_BEGINNING")
		yield($PLAYER/AnimationPlayer, "animation_finished")
		pick_a_random_position()
		self.position += teleport_position
		for i in range(get_slide_count()):
			var _collision = get_slide_collision(i)
			bad_teleportation = true
			self.position = Vector2(720,405)
#		if self.position.x < 50 or self.position.x > 1390 or self.position.y < 50 or self.position.y > 760:
#			print ("OUT OF BOUND!")
#			self.position = Vector2(720,405)
		$PLAYER/AnimationPlayer.play("Teleport_END")
		cooldown_ready = false

func pick_a_random_position():
	var random = rand_range(0,8)
	if random < 1:
		teleport_position = Vector2(0,-200)
	elif random < 2:
		teleport_position = Vector2(200,-10)
	elif random < 3:
		teleport_position = Vector2(200,0)
	elif random < 4:
		teleport_position = Vector2(200,200)
	elif random < 5:
		teleport_position = Vector2(0,200)
	elif random < 6:
		teleport_position = Vector2(-200,200)
	elif random < 7:
		teleport_position = Vector2(-200,0)
	elif random < 8:
		teleport_position = Vector2(-200,-200)

func _on_Cooldown_Timer_timeout():
#	Outline redevient noir !
	$"PLAYER/The Alien (with OUTLINE shader)".material.set_shader_param("cooldown", Color(0.0, 0.0, 0.0, 1.0))
	cooldown_ready = true

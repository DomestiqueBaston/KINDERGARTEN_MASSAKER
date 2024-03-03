tool
extends Runner
class_name Enemy

# running speed
export var speed := Vector2(100, 50)

# distance from the alien where the enemy can attack
export var attack_distance := 50.0

# enemy's default animation
export var default_anim := "Idle"

# enemy's run animation
export var run_anim := "Run"

# the alien, if he can be seen
var alien: Node2D

# direction the enemy is running or facing
var direction: Vector2

# true if the enemy is moving (running)
var is_running: bool

# timer used to regulate the enemy's behavior
var timer: Timer

func _ready():
	if Engine.editor_hint:
		return

	# detect when walking through puddles to update footstep sounds

	start_checking_for_puddles()

	# all characters start out in their default animation, facing in a random
	# direction

	var dir = Globals.get_random_direction()
	direction = dir.normalized()
	$CyclePlayer.set_direction_vector(direction)
	$CyclePlayer.play(default_anim)
	is_running = false

	# set up the timer for updating movements

	timer = Timer.new()
	add_child(timer)
	timer.one_shot = true
	timer.connect("timeout", self, "on_timer_timeout")
	init_timer()

#
# Called once to set the animation timer the first time. May be overridden by
# each character subclass.
#
func init_timer():
	timer.start(rand_range(2, 5) / $CyclePlayer.get_speed())

#
# Called when the animation timer times out to update the character's animation
# state. By default, the character alternates its default and run animations,
# for 2-5 seconds at a time. But the method may be overridden by each character
# subclass.
#
func on_timer_timeout():
	if is_running:
		$CyclePlayer.play(default_anim)
	else:
		$CyclePlayer.play(run_anim)
	is_running = not is_running
	timer.start(rand_range(2, 5) / $CyclePlayer.get_speed())

func _physics_process(delta):
	if not Engine.editor_hint:
		tick(delta)

#
# Called by _physics_process(). If the character's run cycle is playing, the
# character runs in "direction" and tries to avoid obstacles. May be overridden
# by each character subclass.
#
func tick(_delta):
	if (not $AnimationPlayer.current_animation.ends_with(run_anim)
		or $CyclePlayer.is_paused()):
		return
	var dir = move_and_slide(direction * speed * $CyclePlayer.get_speed())
	if get_slide_count() > 0:
		# turn at random when stuck
		if dir.length_squared() < 1.0:
			dir = direction.rotated(rand_range(PI/-4.0, PI/4.0))
		# we can only move in one of the 8 "cardinal" directions
		dir = Globals.get_nearest_direction(dir)
		direction = dir.normalized()
		$CyclePlayer.set_direction_vector(direction)

func set_time_scale(scale = 1.0):
	var prev_scale = 0 if $CyclePlayer.is_paused() else $CyclePlayer.get_speed()
	if scale == prev_scale:
		return
	if scale == 0:
		timer.set_paused(true)
		$CyclePlayer.pause()
	elif prev_scale == 0:
		timer.set_paused(false)
		$CyclePlayer.resume()
	else:
		timer.start(timer.time_left * (prev_scale / scale))
		$CyclePlayer.set_speed(scale)

func freeze(flash=true):
	set_time_scale(0)
	if flash:
		$Flasher.play("flash")

func unfreeze(flash=true):
	set_time_scale(1)
	if flash:
		$Flasher.play("flash")

#
# Turns the character to face the alien.
#
func face_alien():
	if alien:
		var dir = alien.position - position
		dir = Globals.get_nearest_direction(dir)
		direction = dir.normalized()
		$CyclePlayer.set_direction_vector(direction)

#
# Called when the alien has been spotted. The default implementation does
# nothing.
#
func alien_seen():
	pass

#
# Called when the alien can no longer be seen. The default implementation does
# nothing.
#
func alien_gone():
	pass

#
# Connect the alien detector's "body_entered" signal to this method.
#
func on_Alien_Detection_Collider_body_entered(body: Node):
	alien = body
	alien_seen()

#
# Connect the alien detector's "body_exited" signal to this method.
#
func on_Alien_Detection_Collider_body_exited(_body: Node):
	if not $Alien_Detection_Collider/ADCollider.disabled:
		alien = null
		alien_gone()

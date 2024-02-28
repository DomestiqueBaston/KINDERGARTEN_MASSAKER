extends KinematicBody2D

class_name Enemy

export var speed := Vector2(100, 50)
export var default_anim := "Idle"
export var run_anim := "Run"

var timer: Timer
var is_running: bool
var direction: Vector2

func _ready():

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
	timer.start((2 + 3 * randf()) / $CyclePlayer.get_speed())

#
# Called when the animation timer times out, to update the character's animation
# state. May be overridden by each character subclass.
#
func on_timer_timeout():

	# running => stop and idle for 2-5 seconds

	if is_running:
		$CyclePlayer.play(default_anim)

	# not running => start running for 2-5 seconds

	else:
		$CyclePlayer.play(run_anim)

	is_running = not is_running
	timer.start((2 + 3 * randf()) / $CyclePlayer.get_speed())

func _physics_process(_delta):
	if run_anim in $AnimationPlayer.current_animation:
		var time_scale = $CyclePlayer.get_speed()
		if time_scale != 0:
			var dir = move_and_slide(direction * speed * time_scale)
			if get_slide_count() > 0:
				# turn at random when stuck
				if dir.length_squared() < 1.0:
					dir = direction.rotated(rand_range(PI/4.0, PI/4.0))
				# we can only move in one of the 8 "cardinal" directions
				dir = Globals.get_nearest_direction(dir)
				direction = dir.normalized()
				$CyclePlayer.set_direction_vector(direction)

func set_time_scale(scale = 1.0):
	var prev_scale = $CyclePlayer.get_speed()
	if scale == prev_scale:
		return
	if scale == 0:
		timer.set_paused(true)
	elif prev_scale == 0:
		timer.set_paused(false)
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

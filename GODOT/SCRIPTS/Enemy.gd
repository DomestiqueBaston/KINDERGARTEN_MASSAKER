tool
extends Runner
class_name Enemy

# Base class for all enemies (teacher and kids). It handles their movement and
# any behavior that is shared by all of them, such as detecting when the alien
# is and is not visible. It is assumed that all enemies have the following
# three nodes: AnimationPlayer (which contains all the animation cycles),
# CyclePlayer (which pilots the AnimationPlayer) and Flasher (which contains
# the flash animation that is played whenever the enemy is frozen or unfrozen,
# for example).

# running speed
export var speed := Vector2(100, 50)

# distance from the alien where the enemy can attack
export var attack_distance := 50.0

# enemy's default animation
export var default_anim := "Idle"

# enemy's run animation
export var run_anim := "Run"

# the alien, if he has been spotted
var alien: Alien

# is the alien in the enemy's field of vision?
var _alien_visible_flag := false

# is the alien invisible (wherever he is)?
var _alien_invisible_flag := false

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

	# all enemies start out in their default animation, facing in a random
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
# each enemy subclass.
#
func init_timer():
	timer.start(rand_range(2, 5) / $CyclePlayer.get_speed())

#
# Called when the animation timer times out to update the enemy's animation
# state. By default, the enemy alternates its default and run animations, for
# 2-5 seconds at a time. But the method may be overridden by each enemy
# subclass.
#
func on_timer_timeout():
	if is_running:
		$CyclePlayer.play(default_anim)
	else:
		$CyclePlayer.play(run_anim)
	is_running = not is_running
	timer.start(rand_range(2, 5) / $CyclePlayer.get_speed())

#
# Calls the tick() method whenever a physics process signal is received.
# Subclasses should override tick(), if necessary; they should NOT override
# this method, because in that case BOTH _physics_process() methods would be
# called (first the base class's, then the subclass's).
#
func _physics_process(delta):
	if not Engine.editor_hint:
		tick(delta)

#
# Called by _physics_process(). If the enemy's run cycle is playing, the enemy
# runs in "direction" and tries to avoid obstacles. May be overridden by each
# enemy subclass.
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

#
# Sets the time scale for playing back animation cycles (higher values to go
# faster, smaller values to go slower, negative values to go backwards). If
# speed is 0, the playback speed is not actually set; the animation is paused
# instead, until the time scale is reset to a non-zero value.
#
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

#
# Freezes the enemy in time and space until unfreeze() is called. The enemy
# flashes briefly, too, unless flash=false.
#
func freeze(flash=true):
	set_time_scale(0)
	if flash:
		$Flasher.play("flash")

#
# Unfreezes the enemy after a call to freeze(). The enemy flashes briefly, too,
# unless flash=false.
#
func unfreeze(flash=true):
	set_time_scale(1)
	if flash:
		$Flasher.play("flash")

#
# Turns the enemy to face the alien, if the alien is visible.
#
func face_alien():
	if is_alien_visible():
		var dir = alien.position - position
		dir = Globals.get_nearest_direction(dir)
		direction = dir.normalized()
		$CyclePlayer.set_direction_vector(direction)

#
# Turns the enemy so he faces/moves in the opposition direction.
#
func turn_around():
	direction *= -1
	$CyclePlayer.set_direction_vector(direction)

#
# Called when the alien has been seen. The default implementation does nothing.
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
# Connect the alien detector's "body_entered" signal to this method. When the
# alien is detected, alien_seen() is called (unless the alien is invisible).
#
func on_Alien_Detection_Collider_body_entered(body: Node):
	if alien == null:
		alien = body
		_alien_invisible_flag = alien.is_invisible()
		alien.connect("invisible", self, "_on_alien_invisible")
	_alien_visible_flag = true
	if not _alien_invisible_flag:
		alien_seen()

#
# Connect the alien detector's "body_exited" signal to this method. When the
# alien leaves the enemy's field of vision, alien_gone() is called (unless the
# alien is invisible, in which case it makes no difference).
#
func on_Alien_Detection_Collider_body_exited(_body: Node):
	if not $Alien_Detection_Collider/ADCollider.disabled:
		_alien_visible_flag = false
		if not _alien_invisible_flag:
			alien_gone()

#
# This is called when the alien has the invisible talent and makes himself
# invisible, or when the invisibility wears off. If it makes a difference, the
# alien_seen() or alien_gone() method is called.
#
func _on_alien_invisible(var invisible: bool):
	if _alien_invisible_flag != invisible:
		_alien_invisible_flag = invisible
		if _alien_visible_flag:
			if invisible:
				alien_gone()
			else:
				alien_seen()

#
# Returns true if the alien is in the enemy's field of vision and is not
# invisible.
#
func is_alien_visible() -> bool:
	return _alien_visible_flag and not _alien_invisible_flag

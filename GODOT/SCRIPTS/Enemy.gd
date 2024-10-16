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
export var default_animation := "Idle"

# name of the attack animation cycle
export var attack_animation: String

# how long waving lasts
export var wave_time := 2.4

# how long before the enemy can wave again
export var wave_pause_time := 5.0

# the alien, if he has been spotted
var alien: Alien

# is the alien in the enemy's field of vision?
var _alien_visible_flag := false

# is the alien invisible (wherever he is)?
var _alien_invisible_flag := false

# is the view of the alien obstructed by the background?
var _alien_obstructed_flag := false

# square of distance to alien, if known
var _alien_dist2 := 0.0

# direction the enemy is running or facing
var _direction: Vector2

# timer used to regulate the enemy's behavior
var _timer: Timer

# if non-negative, time enemy has been stuck in place (in msec)
var _stuck_time := -1

# if non-negative, time when enemy last waved
var _last_wave_time := -1

# if non-negative, time when repulsion ends
var _repulse_stop := -1

# direction in which enemy is being repulsed
var _repulse_dir: Vector2

func _ready():
	if Engine.editor_hint:
		return

	# detect when walking through puddles to update footstep sounds

	start_checking_for_puddles()

	# all enemies start out in their default animation, facing in a random
	# direction

	var dir = Globals.get_random_direction()
	_direction = dir.normalized()
	$CyclePlayer.set_direction_vector(_direction)
	$CyclePlayer.play(default_animation)

	# set up the timer for updating movements

	_timer = Timer.new()
	add_child(_timer)
	_timer.one_shot = true
	_timer.connect("timeout", self, "on_timer_timeout")
	init_timer()

#
# Returns true if the Enemy instance is being deleted. It seems that the Timer
# is deleted first, so it sometimes happens that the Enemy subclass instance
# is still around but the Timer is not...
#
func is_being_deleted() -> bool:
	return not _timer.is_inside_tree()

#
# Called once to set the internal timer the first time. May be overridden by
# each enemy subclass.
#
func init_timer():
	start_timer(rand_range(2, 5))

#
# Called when the internal timer times out to update the enemy's animation
# state. By default, the enemy alternates its default and run animations, for
# 2-5 seconds at a time. But the method may be overridden by each enemy
# subclass.
#
func on_timer_timeout():
	if $CyclePlayer.get_current_animation() == "Run":
		$CyclePlayer.play(default_animation)
	else:
		$CyclePlayer.play("Run")
	start_timer(rand_range(2, 5))

#
# (Re)starts the internal timer used to regulate the enemy's behavior,
# compensating if the animation playback speed has been modified.
#
func start_timer(t: float):
	_timer.start(t / $CyclePlayer.get_speed())

#
# Stops the internal timer used to regulate the enemy's behavior.
#
func stop_timer():
	_timer.stop()

#
# Calls the tick() method whenever a physics process signal is received.
# Subclasses should override tick(), if necessary; they should NOT override
# this method, because in that case BOTH _physics_process() methods would be
# called (first the base class's, then the subclass's).
#
func _physics_process(delta):
	if not Engine.editor_hint:
		if alien:

			# update distance to alien

			_alien_dist2 = Globals.get_persp_dist_squared(
				alien.position, position)

			# check whether an obstacle blocks the view of the alien
			# (NB. layer 0x01 is the decor, layer 0x02 is the alien)

			var space_state = get_world_2d().direct_space_state
			var raycast = space_state.intersect_ray(
				global_position, alien.global_position, [], 0x03)
			var obstructed = \
				!raycast.empty() and raycast.collider.is_class("StaticBody2D")
			if obstructed != _alien_obstructed_flag:
				_on_alien_obstruction_changed(obstructed)

		tick(delta)

#
# Called by _physics_process(). If the enemy's run cycle is playing, the enemy
# runs in "direction" and tries to avoid obstacles. Except that if repulse()
# has been called, the enemy just slides away from the point of origin that was
# given, for the amount of time that was given. May be overridden by each enemy
# subclass.
#
func tick(delta):
	if _repulse_stop >= 0:
		if Time.get_ticks_msec() < _repulse_stop:
			move_and_collide(_repulse_dir * delta)
		else:
			_repulse_stop = -1
		return

	if ($CyclePlayer.get_current_animation() != "Run"
		or $CyclePlayer.is_paused()):
		return

	# use move_and_collide() to move and avoid collisions

	var vec = _direction * speed * (delta * $CyclePlayer.get_speed())
	var turned = false
	var collision: KinematicCollision2D

	for _i in range(4):
		collision = move_and_collide(vec)
		if collision == null or not want_to_avoid_collider(collision.collider):
			break
		vec = collision.remainder.slide(collision.normal)
		turned = true

	# if the enemy gets stuck, try to free him by turning him around

	if collision == null or collision.remainder == Vector2.ZERO:
		_stuck_time = -1
	else:
		var now = Time.get_ticks_msec()
		if _stuck_time < 0:
			_stuck_time = now
		elif now - _stuck_time > 1000:
			_stuck_time = now
			vec = collision.normal
			turned = true

	# if collisions made the enemy deviate from his path, update his
	# orientation

	if turned:
		_direction = Globals.get_nearest_direction(vec).normalized()
		$CyclePlayer.set_direction_vector(_direction)

#
# Returns true if the enemy wants to get around the given collider object. The
# default implementation always returns true, but Enemy subclasses can override
# the method.
#
func want_to_avoid_collider(_collider: Object) -> bool:
	return true

#
# Sets the time scale for playing back animation cycles: higher values to go
# faster, smaller values to go slower, negative values to go backwards.
#
func set_time_scale(scale: float):
	var prev_scale = $CyclePlayer.get_speed()
	_timer.start(_timer.time_left * (prev_scale / scale))
	$CyclePlayer.set_speed(scale)

#
# Freezes the enemy in time and space until unfreeze() is called.
#
func freeze():
	_timer.set_paused(true)
	$CyclePlayer.pause()
	$Flasher.play("flash")

#
# Unfreezes the enemy after a call to freeze().
#
func unfreeze():
	_timer.set_paused(false)
	$CyclePlayer.resume()
	$Flasher.play("flash")

#
# Stops time until restart_time() is called.
#
func stop_time():
	_timer.set_paused(true)
	$CyclePlayer.pause()

#
# Restarts time after a call to stop_time().
#
func restart_time():
	_timer.set_paused(false)
	$CyclePlayer.resume()

#
# Turns the enemy to face the alien, if the alien is visible.
#
func face_alien():
	if is_alien_visible():
		face_somebody(alien)

#
# Turns the enemy to face any Node2D.
#
func face_somebody(who: Node2D):
	var dir = who.position - position
	if dir.length_squared() < 1.0:
		return
	# this test is to avoid the character jumping back and forth between two
	# directions when he is trying to go somewhere inbetween
	if ($CyclePlayer.get_current_animation() == "Run"
		and abs(_direction.angle_to(dir)) < PI/4.0):
		return
	dir = Globals.get_nearest_direction(dir)
	_direction = dir.normalized()
	$CyclePlayer.set_direction_vector(_direction)

#
# Turns the enemy so he faces/moves in the opposition direction.
#
func turn_around():
	_direction *= -1
	$CyclePlayer.set_direction_vector(_direction)

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
		alien.connect("tree_exiting", self, "_on_alien_dying")
	var was_visible = is_alien_visible()
	_alien_visible_flag = true
	var is_visible = is_alien_visible()
	if is_visible != was_visible:
		alien_seen()

#
# Connect the alien detector's "body_exited" signal to this method. When the
# alien leaves the enemy's field of vision, alien_gone() is called (unless the
# alien is invisible, in which case it makes no difference).
#
func on_Alien_Detection_Collider_body_exited(_body: Node):
	if $Alien_Detection_Collider/ADCollider.disabled:
		return
	var was_visible = is_alien_visible()
	_alien_visible_flag = false
	var is_visible = is_alien_visible()
	if is_visible != was_visible:
		alien_gone()

#
# This is called when the alien has the invisible talent and makes himself
# invisible, or when the invisibility wears off. If it makes a difference, the
# alien_seen() or alien_gone() method is called.
#
func _on_alien_invisible(var invisible: bool):
	var was_visible = is_alien_visible()
	_alien_invisible_flag = invisible
	var is_visible = is_alien_visible()
	if is_visible != was_visible:
		if is_visible:
			alien_seen()
		else:
			alien_gone()

#
# This is called when the view of the alien is obstructed by a piece of the
# decor, or when the obstruction is removed. If it makes a difference, the
# alien_seen() or alien_gone() method is called.
#
func _on_alien_obstruction_changed(obstructed: bool):
	var was_visible = is_alien_visible()
	_alien_obstructed_flag = obstructed
	var is_visible = is_alien_visible()
	if is_visible != was_visible:
		if is_visible:
			alien_seen()
		else:
			alien_gone()

#
# Called when the alien spotted previously is removed from the scene tree.
# This can happen when the alien was actually a mirror image.
#
func _on_alien_dying():
	alien = null
	_alien_visible_flag = false
	_alien_invisible_flag = false
	_alien_obstructed_flag = false

#
# Returns true if the alien is in the enemy's field of vision and is not
# invisible.
#
func is_alien_visible() -> bool:
	return (_alien_visible_flag and not _alien_invisible_flag
			and not _alien_obstructed_flag)

#
# Returns the square of the distance between the enemy and the alien, or zero
# if the alien has not been spotted yet.
#
func get_alien_distance_squared() -> float:
	return _alien_dist2

#
# Returns true if the alien has been spotted at least once and if he is within
# attack range.
#
func is_alien_in_range() -> bool:
	return _alien_dist2 > 0 and _alien_dist2 < attack_distance * attack_distance

#
# The enemy stops to wave at the given kid. Waving lasts for wave_time seconds.
#
func wave_at(kid: Node2D):
	face_somebody(kid)
	$CyclePlayer.play("Waving")
	_timer.start(wave_time)
	_last_wave_time = Time.get_ticks_msec()

#
# Returns true if the enemy is not attacking the alien, is not already waving
# at somebody, and has not waved for wave_pause_time seconds.
#
func _is_ready_to_wave() -> bool:
	if $CyclePlayer.get_current_animation() == attack_animation:
		return false
	if _last_wave_time < 0:
		return true
	return Time.get_ticks_msec() - _last_wave_time > 1000 * wave_pause_time

#
# Connect a kid's waving detection collider's "body_entered" signal to this
# method. If another kid is detected, and both kids are available to wave, they
# do so.
#
# Note that signals should be connected to this method in deferred mode,
# because the animation cycles may enable or disable colliders, triggering an
# error message from Godot if this is done while handling a callback.
#
func on_Kid_Waving_Detection_Collider_body_entered(body: Node):
	if body != self and _is_ready_to_wave() and body._is_ready_to_wave():
		wave_at(body as Node2D)
		body.wave_at(self)

#
# Starts repulsing the enemy: over the given amount of time (in seconds), the
# enemy is pushed the given total distance away from origin.
#
func repulse(origin: Vector2, distance: float, duration: float):
	_repulse_stop = Time.get_ticks_msec() + int(1000 * duration)
	_repulse_dir = Globals.get_persp_velocity(
		origin, position, distance / duration)

#
# Returns true if repulse() has been called and has not finished.
#
func is_repulsed() -> bool:
	return _repulse_stop >= 0

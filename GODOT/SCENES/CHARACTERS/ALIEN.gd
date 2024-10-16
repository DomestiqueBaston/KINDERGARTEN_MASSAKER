tool
extends Runner
class_name Alien

# If the "tool" keyword is not present at the start of the script, the Runner
# class will not be able to play footstep sounds in the Godot editor. It will
# still work in the game, though.

# speed of movement in pixels/second
export var speed := Vector2(125, 62.5)

# likelihood the alien will scratch after a second
export var scratch_chances := 0.25

# how many hit points the alien starts out with
export var initial_hit_points := 1000

# initial hit point muiltiplier for the HEALTH talent
export var health_hit_point_factor := 1.2

# how many hit points the alien receives for his second life
export var second_life_hit_points := 300

# hit points lost when hit by a stick
export var stick_damage := 25

# hit points lost when kicked
export var kick_damage := 75

# hit points lost when spit on
export var spit_damage := 50

# hit points lost when hit by a booger
export var booger_damage := 100

# hit points lost per second when walking in vomit
export var vomit_damage_1 := 50

# hit points lost one second after exiting vomit
export var vomit_damage_2 := 35

# hit points lost two seconds after exiting vomit
export var vomit_damage_3 := 15

# hit points recovered per second with REGENERATE talent
export var regen_hit_points := 5

# HAND_TO_HAND talent: multiplier for short-range attack damage
export var hand_to_hand_short_range_damage_factor := 0.5

# HAND_TO_HAND talent: multiplier for long-range attack damage
export var hand_to_hand_long_range_damage_factor := 1.25

# RANGED_COMBAT talent: multiplier for short-range attack damage
export var ranged_combat_short_range_damage_factor := 1.5

# RANGED_COMBAT talent: multiplier for long-range attack damage
export var ranged_combat_long_range_damage_factor := 0.75

# signal emitted when the beam down animation has finished
signal beam_down_finished

# signal emitted when the alien is ready to teleport
signal teleport

# signal emitted when the ghost effect wears off
signal ghost_done

# signal emitted when the alien becomes visible or invisible
signal invisible

# signal emitted when the alien is reborn
signal second_life

# signal emitted when the alien runs out of hit points
signal dead

var _direction := Vector2.DOWN
var _talent := -1
var _scratch_interval := 0.0
var _accelerate := 1.0
var _mirror := false
var _invisible_flag := false
var _hit_points := 0
var _vomit_exit_time := -1
var _death_count := 0

enum State {
	FIRST_IDLE,
	SCRATCH,
	IDLE,
	MOVE,
	HIT,
	DEAD
}

var _state = State.MOVE

func _ready():
	if Engine.editor_hint:
		return
	var cycle_length = $AnimationPlayer.get_animation("00_Idle").length
	_scratch_interval = cycle_length - 1.0 / Globals.FPS
	$CyclePlayer.set_direction_vector(_direction)
	set_physics_process(false)
	# alien can't be seen until he beams down
	$Move_Collider.disabled = true

#
# Starts the alien's "idle" animation cycle and beams him down. Once the "beam
# down" animation has finished, physics processing is turned on (so he can move)
# and a "beam_down_finished" signal is emitted.
#
func beam_down(talent: int):
	_talent = talent
	$CyclePlayer.play("Idle")
	start_checking_for_puddles()
	$Beam_Down_Rear/AnimationPlayer.play("Beam_Down")
	# to ensure alien is invisible, in particular...
	$Beam_Down_Rear/AnimationPlayer.advance(0)

func _on_beam_down_finished(_anim_name):
	_hit_points = initial_hit_points
	if _talent == Globals.Talent.HEALTH:
		_hit_points = int(_hit_points * health_hit_point_factor)
	elif _talent == Globals.Talent.REGENERATE:
		$Talent/Regen_Timer.start()
	$Move_Collider.set_deferred("disabled", false)
	set_physics_process(true)
	emit_signal("beam_down_finished")

#
# Returns true if the alien is busy: scratching himself, getting hit, or dead.
#
func is_busy() -> bool:
	# NB. The SCRATCH state begins a bit BEFORE the Scratching animation, and
	# the DEAD state goes on after the Dead animation...
	return (_state in [State.SCRATCH, State.DEAD] or
			$CyclePlayer.get_current_animation() == "Hit")

func _physics_process(_delta):

	# if we're in the Godot editor, we don't want any of this to be done, but
	# since the "tool" keyword appears at the top of the script, this method is
	# called anyway...

	if Engine.editor_hint:
		return

	# a mirror image alien just moves automatically

	if _mirror:
		var dir = move_and_slide(_direction * speed * _accelerate)
		if get_slide_count() > 0:
			_direction = dir.normalized()
			$CyclePlayer.set_direction_vector(_direction)
		return

	# can't do anything else while scratching or being hit, or if dead

	if is_busy():
		return

	# check for movement inputs

	var dir = Vector2.ZERO
	if (Input.is_action_pressed("ui_left") or
		Input.is_action_pressed("ui_up_left") or
		Input.is_action_pressed("ui_down_left")):
		dir.x -= 1
	if (Input.is_action_pressed("ui_right") or
		Input.is_action_pressed("ui_up_right") or
		Input.is_action_pressed("ui_down_right")):
		dir.x += 1
	if (Input.is_action_pressed("ui_up") or
		Input.is_action_pressed("ui_up_left") or
		Input.is_action_pressed("ui_up_right")):
		dir.y -= 1
	if (Input.is_action_pressed("ui_down") or
		Input.is_action_pressed("ui_down_left") or
		Input.is_action_pressed("ui_down_right")):
		dir.y += 1

	# no movement inputs => idle or maybe scratch

	if dir == Vector2.ZERO:
		var next_state = _state

		if _state == State.MOVE:
			next_state = State.FIRST_IDLE
		elif (_state == State.FIRST_IDLE and
			  "Idle" in $AnimationPlayer.current_animation and
			  $AnimationPlayer.current_animation_position >= _scratch_interval):
			if randf() < scratch_chances:
				next_state = State.SCRATCH
			else:
				next_state = State.IDLE
		elif _state == State.HIT:
			next_state = State.IDLE

		if _state != next_state:
			if next_state == State.SCRATCH:
				$CyclePlayer.play("Idle", true)
				$CyclePlayer.play("Scratching", true)
			$CyclePlayer.play("Idle")
			_state = next_state

	# otherwise => run

	else:
		_state = State.MOVE
		_direction = dir.normalized()
		$CyclePlayer.set_direction_vector(_direction)
		$CyclePlayer.play("Run")
		move_and_slide(_direction * speed * _accelerate)

#
# Sets a multiplier for the speed of the alien's Run animation cycle (1 by
# default).
#
func set_run_cycle_speed(multiplier: float):
	$CyclePlayer.set_speed(multiplier)

#
# Sets a multiplier for the speed of the alien's movements (1 by default).
#
func set_run_speed(multiplier: float):
	_accelerate = multiplier

#
# Starts the alien's teleport animation, emits a "teleport" signal, then
# finishes the teleport animation.
#
func start_teleport():
	$Talent/Teleport/AnimationPlayer.play("Teleport_BEGINNING")
	yield($Talent/Teleport/AnimationPlayer, "animation_finished")
	emit_signal("teleport")
	$Talent/Teleport/AnimationPlayer.play("Teleport_END")

#
# Makes the alien invisible for the given time, in seconds.
#
func start_invisible(duration: float):
	$Talent/Invisible.start(duration)
	_invisible_flag = true
	emit_signal("invisible", _invisible_flag)

func _on_invisible_done():
	_invisible_flag = false
	emit_signal("invisible", _invisible_flag)

#
# Interrupts the "invisible" animation in progress.
#
func stop_invisible():
	$Talent/Invisible.stop()
	_invisible_flag = false
	emit_signal("invisible", _invisible_flag)

#
# Returns true if the alien is invisible (start_invisible() has been called).
#
func is_invisible() -> bool:
	return _invisible_flag

#
# Plays the explosion animation.
#
func start_explosion():
	$Talent/Explosion/AnimationPlayer.play("explosion")

#
# Plays the freeze animation.
#
func start_freeze():
	$Talent/Freezing_Shockwave/AnimationPlayer.play("Freezing_Shockwave")

#
# Plays the shield animation for the given time, in seconds.
#
func start_shield(duration: float):
	$Talent/Shield.start(duration)

#
# Interrupts the shield animation in progress.
#
func stop_shield():
	$Talent/Shield.stop()

#
# Plays the force field animation for the given time, in seconds.
#
func start_force_field(duration: float):
	$Talent/Force_Field.start(duration)

#
# Interrupts the force field animation in progress.
#
func stop_force_field():
	$Talent/Force_Field.stop()

#
# Starts this alien going in mirror mode: it will run randomly, starting at the
# given position and facing in the given direction (which is NOT normalized but
# contains only zeros and ones). When the given time has elapsed, the alien will
# self-destruct.
#
func start_mirror(duration: float, pos: Vector2, dir: Vector2):
	flash()
	_mirror = true
	position = pos
	_direction = dir.normalized()
	$CyclePlayer.set_direction_vector(dir)
	$CyclePlayer.play("Run")
	start_checking_for_puddles()
	$Move_Collider.set_deferred("disabled", false)
	set_physics_process(true)
	var flash_time = $Flash.get_animation("flash").length
	var timer = Timer.new()
	add_child(timer)
	timer.one_shot = true
	timer.connect("timeout", self, "_stop_mirror")
	timer.start(max(0, duration - flash_time))

func _stop_mirror():
	flash()
	$Talent/Mirror_Images/PLOP.play()
	yield($Flash, "animation_finished")
	queue_free()

#
# Plays the ghost animation.
#
func start_ghost():
	$Talent/Ghost.start()

func _on_ghost_done():
	emit_signal("ghost_done")

#
# Returns true if the ghost animation is running.
#
func is_ghost_running() -> bool:
	return $Talent/Ghost.is_running()

#
# Interrupts the ghost animation in progress.
#
func stop_ghost():
	$Talent/Ghost.stop()

#
# Starts cooldown: the alien is outlined in red for the given time, in seconds.
#
func start_cooldown(duration: float):
	$Cooldown_Timer.start(
		max(0, duration - $Cooldown.get_animation("cooldown_off").length))
	$Cooldown.play("cooldown_on")

func _on_Cooldown_Timer_timeout():
	$Cooldown.play("cooldown_off")

#
# Interrupts the cooldown in progress, if there is one.
#
func stop_cooldown():
	$Cooldown_Timer.stop() 
	$Cooldown.play("RESET")

#
# Returns true if a cooldown is in progress.
#
func is_cooldown_active() -> bool:
	return not $Cooldown_Timer.is_stopped()

#
# Causes the alien to flash on and off. If brief is true, he only flashes on
# and off once, very quickly.
#
func flash(var brief := false):
	$Flash.play("flash_brief" if brief else "flash")

func _on_AnimationPlayer_animation_changed(old_name, _new_name):
	if _state == State.SCRATCH and old_name.ends_with("_Scratching"):
		_state = State.IDLE

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name.ends_with("_Dead"):
		_start_second_life()

func _on_Hit_Collider_area_entered(area: Area2D):
	if _mirror:
		_stop_mirror()
		return
	if $Talent/Ghost.is_running():
		return

	var damage = 0
	var short_range: bool

	match area.owner.weapon_type:
		Globals.Weapon.STICK:
			damage = stick_damage
			short_range = true
		Globals.Weapon.KICK:
			damage = kick_damage
			short_range = true
		Globals.Weapon.BOOGER:
			damage = booger_damage
			short_range = false
		Globals.Weapon.SPIT:
			damage = spit_damage
			short_range = false

	match _talent:
		Globals.Talent.FORCE_FIELD:
			if not short_range and $Talent/Force_Field.is_running():
				damage = 0
		Globals.Talent.SHIELD:
			if short_range and $Talent/Shield.is_running():
				damage = 0
		Globals.Talent.HAND_TO_HAND:
			if short_range:
				damage = int(damage * hand_to_hand_short_range_damage_factor)
			else:
				damage = int(damage * hand_to_hand_long_range_damage_factor)
		Globals.Talent.RANGED_COMBAT:
			if short_range:
				damage = int(damage * ranged_combat_short_range_damage_factor)
			else:
				damage = int(damage * ranged_combat_long_range_damage_factor)
		Globals.Talent.GHOST:
			if $Talent/Ghost.is_running():
				damage = 0

	if damage > 0:
		_take_hit_points(damage)
		if _hit_points > 0:
			_state = State.HIT
			flash(true)
			$CyclePlayer.stop()
			$CyclePlayer.play("Hit", true)
			$CyclePlayer.play("Idle")

func vomit_entered():
	_take_vomit_hit_points(vomit_damage_1)
	_vomit_exit_time = -1
	$Vomit_Timer.start()

func vomit_exited():
	_vomit_exit_time = Time.get_ticks_msec()

func _on_Vomit_Timer_timeout():
	if _vomit_exit_time < 0:
		_take_vomit_hit_points(vomit_damage_1)
	elif (Time.get_ticks_msec() - _vomit_exit_time) < 1000:
		_take_vomit_hit_points(vomit_damage_2)
	else:
		_take_vomit_hit_points(vomit_damage_3)
		$Vomit_Timer.stop()

func _take_vomit_hit_points(damage: int):
	if _talent == Globals.Talent.VOMIT_PROOF:
		damage /= 2
	else:
		flash(true)
	_take_hit_points(damage)

func _take_hit_points(damage: int):
	if _mirror:
		return
	if damage > 0 and (_state == State.DEAD or $Talent/Ghost.is_running()):
		return
	_hit_points = int(max(0, _hit_points - damage))
	if Globals.VERBOSE:
		print("hit points: ", _hit_points)
	if _hit_points <= 0:
		_state = State.DEAD
		if _talent == Globals.Talent.SECOND_LIFE and _death_count == 0:
			_end_first_life()
		else:
			emit_signal("dead")

func _end_first_life():
	_death_count += 1

	# no more damage from vomit and attackers

	_vomit_exit_time = -1
	$Vomit_Timer.stop()
	_invisible_flag = true
	emit_signal("invisible", _invisible_flag)

	# the end of the Dead animation triggers the second life

	$CyclePlayer.stop()
	$CyclePlayer.play("Dead", true, false)

func _start_second_life():

	# flash flash flash and start Idle animation

	$Talent/Second_Life_Timer.start(1)
	yield($Talent/Second_Life_Timer, "timeout")
	$Flash.play("flash_loop")
	$Talent/Second_Life_Timer.start(1)
	yield($Talent/Second_Life_Timer, "timeout")
	emit_signal("second_life")
	$CyclePlayer.play("Idle")
	$Talent/Second_Life_Timer.start(2)
	yield($Talent/Second_Life_Timer, "timeout")
	$Flash.play("RESET")

	# restore hit points and start taking damage from vomit and attackers again

	_take_hit_points(-second_life_hit_points)
	_invisible_flag = false
	emit_signal("invisible", _invisible_flag)

	_state = State.IDLE

func _on_Regen_Timer_timeout():
	var added_points = int(
		min(regen_hit_points, initial_hit_points - _hit_points))
	if added_points > 0:
		_take_hit_points(-added_points)

#
# Returns the location of the alien's hit collider in global coordinates.
#
func get_hit_target() -> Vector2:
	return $Hit_Collider/HCollider.global_position

#
# Sets the size of the alien's hit collider, making it smaller and harder to
# hit if small=true.
#
func set_hit_collider_size(small: bool):
	var capsule: CapsuleShape2D = $Hit_Collider/HCollider.shape
	if small:
		capsule.radius = 11
		capsule.height = 4
	else:
		capsule.radius = 14
		capsule.height = 4.05

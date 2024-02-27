extends KinematicBody2D

class_name Alien

# speed of movement in pixels/second
export var speed := Vector2(125, 62.5)

# likelihood the alien will scratch after a second
export var scratch_chances := 0.25

# signal emitted when the beam down animation has finished
signal beam_down_finished

# signal emitted when the alien is ready to teleport
signal teleport

# signal emitted when the ghost effect wears off
signal ghost_done

# sounds of footsteps (dry and wet, right and left)
var dry_step = [
	preload("res://ASSETS/SOUND/FX/ALIEN/Barefoot_steps_A.wav"),
	preload("res://ASSETS/SOUND/FX/ALIEN/Barefoot_steps_B.wav")
]
var wet_step = [
	preload("res://ASSETS/SOUND/FX/ALIEN/Mud_steps_C.wav"),
	preload("res://ASSETS/SOUND/FX/ALIEN/Mud_steps_E.wav")
]

var direction := Vector2.DOWN
var scratch_interval := 0.0
var accelerate := 1.0
var mirror := false
var is_ground_wet := false

enum State {
	FIRST_IDLE,
	SCRATCH,
	IDLE,
	MOVE
}

var state = State.MOVE

func _ready():
	reset()

#
# Returns the alien to its initial state: facing forward, no animation, no
# physics processing (movement), and no cooldown.
#
func reset():
	direction = Vector2.DOWN
	scratch_interval = $AnimationPlayer.get_animation("00_Idle").length - 0.1
	$CyclePlayer.set_direction_vector(direction)
	$CyclePlayer.stop()
	set_physics_process(false)
	stop_cooldown()
	state = State.MOVE

#
# Starts the alien's "idle" animation cycle and beams him down. Once the "beam
# down" animation has finished, physics processing is turned on (so he can move)
# and a "beam_down_finished" signal is emitted.
#
func beam_down():
	$CyclePlayer.play("Idle")
	$Beam_Down_Rear/AnimationPlayer.play("Beam_Down")
	# to ensure alien is invisible, in particular...
	$Beam_Down_Rear/AnimationPlayer.advance(0)

func _on_beam_down_finished(_anim_name):
	set_physics_process(true)
	emit_signal("beam_down_finished")

#
# Returns true if the alien is busy scratching himself.
#
func is_scratching() -> bool:
	return state == State.SCRATCH

func _physics_process(_delta):

	# a mirror image alien just moves automatically

	if mirror:
		var dir = move_and_slide(direction * speed * accelerate)
		if get_slide_count() > 0:
			direction = dir.normalized()
			$CyclePlayer.set_direction_vector(direction)
		return

	# can't do anything else while scratching

	if is_scratching():
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
		var next_state = state

		if state == State.MOVE:
			next_state = State.FIRST_IDLE
		elif (state == State.FIRST_IDLE and
			  "Idle" in $AnimationPlayer.current_animation and
			  $AnimationPlayer.current_animation_position >= scratch_interval):
			if randf() < scratch_chances:
				next_state = State.SCRATCH
			else:
				next_state = State.IDLE

		if state != next_state:
			if next_state == State.SCRATCH:
				$CyclePlayer.play("Idle", true)
				$CyclePlayer.play("Scratching", true)
			$CyclePlayer.play("Idle")
			state = next_state

	# otherwise => run

	else:
		state = State.MOVE
		direction = dir.normalized()
		$CyclePlayer.set_direction_vector(direction)
		$CyclePlayer.play("Run")
		move_and_slide(direction * speed * accelerate)

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
	accelerate = multiplier

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
	mirror = true
	position = pos
	direction = dir.normalized()
	$CyclePlayer.set_direction_vector(dir)
	$CyclePlayer.play("Run")
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
# Causes the alien to flash on and off briefly.
#
func flash():
	$Flash.play("flash")

func _on_AnimationPlayer_animation_changed(old_name, _new_name):
	if state == State.SCRATCH and "Scratching" in old_name:
		state = State.IDLE

#
# Called by AnimationPlayer when the alien takes a step to play an appropriate
# sound.
#
func play_step(left: bool):
	var index = 1 if left else 0
	if is_ground_wet:
		$Footsteps.stream = wet_step[index]
	else:
		$Footsteps.stream = dry_step[index]
	#yield(get_tree().create_timer(delay), "timeout")
	$Footsteps.play()

func _on_Hit_Collider_area_entered(_area: Area2D):
	is_ground_wet = true

func _on_Hit_Collider_area_exited(_area: Area2D):
	is_ground_wet = false

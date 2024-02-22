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

var state_machine: AnimationNodeStateMachinePlayback
var direction := Vector2.DOWN
var accelerate := 1.0
var mirror := false

enum State {
	FIRST_IDLE,
	SCRATCH,
	IDLE,
	MOVE
}

var state = State.MOVE

func _ready():
	$AnimationTree.active = true
	state_machine = $AnimationTree["parameters/playback"]
	reset()

#
# Returns the alien to its initial state: facing forward, no animation, no
# physics processing (movement), and no cooldown.
#
func reset():
	direction = Vector2.DOWN
	$AnimationTree["parameters/Idle/blend_position"] = direction
	$AnimationTree["parameters/Scratching/blend_position"] = direction
	$AnimationTree["parameters/Run/Blend/blend_position"] = direction
	$AnimationTree["parameters/Run/TimeScale/scale"] = 1
	set_physics_process(false)
	stop_cooldown()
	state_machine.stop()
	state = State.MOVE

#
# Starts the alien's "idle" animation cycle and beams him down. Once the "beam
# down" animation has finished, physics processing is turned on (so he can move)
# and a "beam_down_finished" signal is emitted.
#
func beam_down():
	state_machine.travel("Idle")
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

	# NB. state may be set to SCRATCHING in _physics_process() as soon as the
	# alien first starts idling, but he doesn't actually start scratching until
	# the end of the idle cycle is reached, which is why we need to test the
	# current node in the state machine

	return (state == State.SCRATCHING and
			state_machine.get_current_node() == "Scratching")

func _physics_process(_delta):

	# a mirror image alien just moves automatically

	if mirror:
		move_and_slide(direction * speed * accelerate)
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
		elif state == State.FIRST_IDLE and randf() < scratch_chances:
			next_state = State.SCRATCH
		elif state != State.SCRATCH:
			next_state = State.IDLE

		# NB. transitions in the animation tree to/from Scratching are in "at
		# end" switch mode, so a switch between Scratching and Idle doesn't
		# happen right away

		if state != next_state:
			if next_state == State.SCRATCH:
				state_machine.travel("Scratching")
			else:
				state_machine.travel("Idle")
			state = next_state

	# otherwise => run

	else:
		$AnimationTree["parameters/Idle/blend_position"] = dir
		$AnimationTree["parameters/Scratching/blend_position"] = dir
		$AnimationTree["parameters/Run/Blend/blend_position"] = dir
		state_machine.travel("Run")
		state = State.MOVE
		direction = dir.normalized()
		move_and_slide(direction * speed * accelerate)

#
# Sets a multiplier for the speed of the alien's Run animation cycle (1 by
# default).
#
func set_run_cycle_speed(multiplier: float):
	$AnimationTree["parameters/Run/TimeScale/scale"] = multiplier

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
# Plays the force field animation for the given time, in seconds.
#
func start_force_field(duration: float):
	$Talent/Force_Field.start(duration)

#
# Starts this alien going in mirror mode: it will run randomly, starting at the
# given position and facing in the given direction (which is NOT normalized but
# contains only zeros and ones). When the given time has elapsed, the alien will
# self-destruct.
#
func start_mirror(duration: float, pos: Vector2, dir: Vector2):
	position = pos
	$AnimationTree["parameters/Run/Blend/blend_position"] = dir
	direction = dir.normalized()
	state_machine.travel("Run")
	flash()
	mirror = true
	set_physics_process(true)
	var flash_time = $Flasher.get_animation("flash").length
	var timer = Timer.new()
	add_child(timer)
	timer.one_shot = true
	timer.connect("timeout", self, "_stop_mirror")
	timer.start(max(0, duration - flash_time))

func _stop_mirror():
	flash()
	yield($Flash, "animation_finished")
	queue_free()

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

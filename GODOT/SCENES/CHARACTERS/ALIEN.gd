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

# signal emitted when the beam down animation has finished
signal beam_down_finished

# signal emitted when the alien is ready to teleport
signal teleport

# signal emitted when the ghost effect wears off
signal ghost_done

# signal emitted when the alien becomes visible or invisible
signal invisible

var direction := Vector2.DOWN
var scratch_interval := 0.0
var accelerate := 1.0
var mirror := false
var invisible_flag := false

enum State {
	FIRST_IDLE,
	SCRATCH,
	IDLE,
	MOVE,
	HIT
}

var state = State.MOVE

func _ready():
	if not Engine.editor_hint:
		reset()

#
# Returns the alien to its initial state: facing forward, no animation, no
# physics processing (movement), and no cooldown.
#
func reset():
	var cycle_length = $AnimationPlayer.get_animation("00_Idle").length
	scratch_interval = cycle_length - 1.0 / Globals.FPS
	direction = Vector2.DOWN
	$CyclePlayer.set_direction_vector(direction)
	$CyclePlayer.stop()
	set_physics_process(false)
	stop_cooldown()
	mirror = false
	invisible_flag = false
	state = State.MOVE
	stop_checking_for_puddles()
	# alien can't be seen until he beams down
	$Move_Collider.set_deferred("disabled", true)

#
# Starts the alien's "idle" animation cycle and beams him down. Once the "beam
# down" animation has finished, physics processing is turned on (so he can move)
# and a "beam_down_finished" signal is emitted.
#
func beam_down():
	$CyclePlayer.play("Idle")
	start_checking_for_puddles()
	$Beam_Down_Rear/AnimationPlayer.play("Beam_Down")
	# to ensure alien is invisible, in particular...
	$Beam_Down_Rear/AnimationPlayer.advance(0)

func _on_beam_down_finished(_anim_name):
	$Move_Collider.set_deferred("disabled", false)
	set_physics_process(true)
	emit_signal("beam_down_finished")

#
# Returns true if the alien is busy scratching himself or getting hit.
#
func is_busy() -> bool:
	# NB. The SCRATCH state begins a bit BEFORE the Scratching animation
	return (state == State.SCRATCH or
			$AnimationPlayer.current_animation.ends_with("_Hit"))

func _physics_process(_delta):

	# if we're in the Godot editor, we don't want any of this to be done, but
	# since the "tool" keyword appears at the top of the script, this method is
	# called anyway...

	if Engine.editor_hint:
		return

	# a mirror image alien just moves automatically

	if mirror:
		var dir = move_and_slide(direction * speed * accelerate)
		if get_slide_count() > 0:
			direction = dir.normalized()
			$CyclePlayer.set_direction_vector(direction)
		return

	# can't do anything else while scratching or being hit

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
		elif state == State.HIT:
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
	invisible_flag = true
	emit_signal("invisible", invisible_flag)

func _on_invisible_done():
	invisible_flag = false
	emit_signal("invisible", invisible_flag)

#
# Interrupts the "invisible" animation in progress.
#
func stop_invisible():
	$Talent/Invisible.stop()
	invisible_flag = false
	emit_signal("invisible", invisible_flag)

#
# Returns true if the alien is invisible (start_invisible() has been called).
#
func is_invisible() -> bool:
	return invisible_flag

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
	if state == State.SCRATCH and old_name.ends_with("_Scratching"):
		state = State.IDLE

func _on_Hit_Collider_area_entered(_area: Area2D):
	state = State.HIT
	flash(true)
	$CyclePlayer.stop()
	$CyclePlayer.play("Hit", true)
	$CyclePlayer.play("Idle")

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

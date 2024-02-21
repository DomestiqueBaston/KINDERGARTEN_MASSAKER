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

func reset():
	direction = Vector2.DOWN
	$AnimationTree["parameters/Idle/blend_position"] = direction
	$AnimationTree["parameters/Scratching/blend_position"] = direction
	$AnimationTree["parameters/Run/Blend/blend_position"] = direction
	$AnimationTree["parameters/Run/TimeScale/scale"] = 1
	set_physics_process(false)
	stop_cooldown()
	state_machine.stop()

func beam_down():
	state_machine.travel("Idle")
	$Beam_Down_Rear/AnimationPlayer.play("Beam_Down")
	# to ensure alien is invisible, in particular...
	$Beam_Down_Rear/AnimationPlayer.advance(0)

func _on_beam_down_finished(_anim_name):
	set_physics_process(true)
	emit_signal("beam_down_finished")

func _physics_process(_delta):
	if mirror:
		move_and_slide(direction * speed * accelerate)
		return

	if state == State.SCRATCH and state_machine.get_current_node() == "Scratching":
		return

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

	if dir == Vector2.ZERO:
		var next_state = state
		if state == State.MOVE:
			next_state = State.FIRST_IDLE
		elif state == State.FIRST_IDLE and randf() < scratch_chances:
			next_state = State.SCRATCH
		elif state != State.SCRATCH:
			next_state = State.IDLE
		if state != next_state:
			if next_state == State.SCRATCH:
				state_machine.travel("Scratching")
			else:
				state_machine.travel("Idle")
			state = next_state
	else:
		$AnimationTree["parameters/Idle/blend_position"] = dir
		$AnimationTree["parameters/Scratching/blend_position"] = dir
		$AnimationTree["parameters/Run/Blend/blend_position"] = dir
		state_machine.travel("Run")
		state = State.MOVE
		direction = dir.normalized()
		move_and_slide(direction * speed * accelerate)

func set_run_cycle_speed(multiplier: float):
	$AnimationTree["parameters/Run/TimeScale/scale"] = multiplier

func set_run_speed(multiplier: float):
	accelerate = multiplier

func start_teleport():
	$Talent/Teleport/AnimationPlayer.play("Teleport_BEGINNING")
	yield($Talent/Teleport/AnimationPlayer, "animation_finished")
	emit_signal("teleport")
	$Talent/Teleport/AnimationPlayer.play("Teleport_END")

func start_invisible(duration: float):
	$Talent/Invisible.start(duration)

func start_explosion():
	$Talent/Explosion/AnimationPlayer.play("explosion")

func start_freeze():
	$Talent/Freezing_Shockwave/AnimationPlayer.play("Freezing_Shockwave")

func start_shield(duration: float):
	$Talent/Shield.start(duration)

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
	yield($Flasher, "animation_finished")
	queue_free()

func start_cooldown():
	$Alien.material.set_shader_param("cooldown", Color(0xb73847ff))

func stop_cooldown():
	$Alien.material.set_shader_param("cooldown", Color(0x000000ff))

func flash():
	$Flasher.play("flash")

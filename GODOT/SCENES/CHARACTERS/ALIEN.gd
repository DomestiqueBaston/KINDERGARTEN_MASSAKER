extends KinematicBody2D

class_name Alien

# speed of movement in pixels/second
export var speed = Vector2(125, 62.5)

# likelihood the alien will scratch after a second
export var scratch_chances = 0.25

# signal emitted when the beam down animation has finished
signal beam_down_finished

# signal emitted when the alien is ready to teleport
signal teleport

var state_machine: AnimationNodeStateMachinePlayback
var direction = Vector2.DOWN
var accelerate = 1.0

enum State {
	FIRST_IDLE,
	SCRATCH,
	IDLE,
	MOVE
}

var state = State.MOVE

func _ready():
	state_machine = $AnimationTree["parameters/playback"]
	reset()

func reset():
	direction = Vector2.DOWN
	$AnimationTree["parameters/Idle/blend_position"] = direction
	$AnimationTree["parameters/Scratching/blend_position"] = direction
	$AnimationTree["parameters/Run/blend_position"] = direction
	set_physics_process(false)
	stop_cooldown()

func beam_down():
	$Beam_Down_Rear/AnimationPlayer.play("Beam_Down")

func _on_beam_down_finished(_anim_name):
	set_physics_process(true)
	emit_signal("beam_down_finished")

func _physics_process(delta):
	if state == State.SCRATCH and state_machine.get_current_node() == "Scratching":
		return

	var dir = Vector2.ZERO
	if Input.is_action_pressed("ui_left"):
		dir.x -= 1
	if Input.is_action_pressed("ui_right"):
		dir.x += 1
	if Input.is_action_pressed("ui_up"):
		dir.y -= 1
	if Input.is_action_pressed("ui_down"):
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
		$AnimationTree["parameters/Run/blend_position"] = dir
		state_machine.travel("Run")
		state = State.MOVE
		direction = dir.normalized()
		var _collision = move_and_collide(direction * speed * accelerate * delta)

func start_teleport():
	$Talent/Teleport/AnimationPlayer.play("Teleport_BEGINNING")
	yield($Talent/Teleport/AnimationPlayer, "animation_finished")
	emit_signal("teleport")
	$Talent/Teleport/AnimationPlayer.play("Teleport_END")

func start_dash():
	$Talent/Dash/FX.play()
	accelerate = 5.0

func stop_dash():
	accelerate = 1.0

func start_cooldown():
	$Alien.material.set_shader_param("cooldown", Color(0xb73847ff))

func stop_cooldown():
	$Alien.material.set_shader_param("cooldown", Color(0x000000ff))

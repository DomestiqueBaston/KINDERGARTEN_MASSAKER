extends KinematicBody2D

class_name Alien

# speed of movement in pixels/second
export var speed = Vector2(125, 62.5)

# likelihood the alien will scratch after a second
export var scratch_chances = 0.25

# signal emitted when the beam down animation has finished
signal beam_down_finished

# signal emitted when the alien teleports
signal teleport

var anim_tree: AnimationTree
var state_machine: AnimationNodeStateMachinePlayback
var direction = Vector2.ZERO
var talent = -1
var cooldown_timer: Timer
var in_cooldown = false

enum State {
	FIRST_IDLE,
	SCRATCH,
	IDLE,
	MOVE
}

var state = State.MOVE

func _ready():
	anim_tree = $AnimationTree
	anim_tree.set_active(true)
	anim_tree["parameters/Idle/blend_position"] = Vector2.DOWN
	anim_tree["parameters/Scratching/blend_position"] = Vector2.DOWN
	anim_tree["parameters/Run/blend_position"] = Vector2.DOWN
	state_machine = anim_tree["parameters/playback"]
	set_process_unhandled_input(false)
	set_physics_process(false)
	_stop_cooldown()

func _on_beam_down_finished(_anim_name):
	set_process_unhandled_input(true)
	set_physics_process(true)
	emit_signal("beam_down_finished")

func _unhandled_input(event):
	if not in_cooldown and event.is_action_pressed("ui_accept", false, true):
		if talent == Globals.Talent.TELEPORT:
			_start_teleport()
		get_tree().set_input_as_handled()

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
		anim_tree["parameters/Idle/blend_position"] = dir
		anim_tree["parameters/Scratching/blend_position"] = dir
		anim_tree["parameters/Run/blend_position"] = dir
		state_machine.travel("Run")
		state = State.MOVE
		direction = dir.normalized()
		var _collision = move_and_collide(direction * speed * delta)

func set_talent(talent_index: int):
	if talent >= 0:
		printerr("alien already has a talent")
		return
	talent = talent_index
	match talent:
		Globals.Talent.TELEPORT:
			cooldown_timer = $Talent/Teleport/Cooldown_Timer
			cooldown_timer.connect("timeout", self, "_stop_cooldown")

func _start_teleport():
	_start_cooldown()
	cooldown_timer.start()
	var anim = $Talent/Teleport/AnimationPlayer
	anim.play("Teleport_BEGINNING")
	yield(anim, "animation_finished")
	emit_signal("teleport")
	anim.play("Teleport_END")

func _start_cooldown():
	in_cooldown = true
	$Alien.material.set_shader_param("cooldown", Color(0xb73847ff))

func _stop_cooldown():
	in_cooldown = false
	$Alien.material.set_shader_param("cooldown", Color(0x000000ff))

extends KinematicBody2D

# speed of movement in pixels/second
export var speed = Vector2(125, 62.5)

# likelihood the alien will scratch after a second
export var scratch_chances = 0.25

var anim_tree
var state_machine
var direction = Vector2.ZERO

enum State {
	FIRST_IDLE,
	SCRATCH,
	IDLE,
	MOVE
}

var state = State.MOVE

func _ready():
	randomize()
	anim_tree = $AnimationTree
	anim_tree.set_active(true)
	anim_tree["parameters/Idle/blend_position"] = Vector2.DOWN
	anim_tree["parameters/Scratching/blend_position"] = Vector2.DOWN
	anim_tree["parameters/Run/blend_position"] = Vector2.DOWN
	state_machine = anim_tree["parameters/playback"]

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

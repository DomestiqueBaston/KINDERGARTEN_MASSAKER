extends KinematicBody2D

class_name Enemy

export var char_name: String
export var speed := Vector2(100, 50)
export var default_anim := "Idle"
export var run_anim := "Run"

var idle_blend_param: String
var run_blend_param: String
var idle_time_param: String
var run_time_param: String
var timer: Timer
var is_running: bool
var state_machine: AnimationNodeStateMachinePlayback
var direction: Vector2

func _ready():
	$AnimationTree.active = true
	state_machine = $AnimationTree["parameters/playback"]
	idle_blend_param = "parameters/%s/BlendSpace2D/blend_position" % default_anim
	run_blend_param = "parameters/%s/BlendSpace2D/blend_position" % run_anim
	idle_time_param = "parameters/%s/TimeScale/scale" % default_anim
	run_time_param = "parameters/%s/TimeScale/scale" % run_anim

	# all characters start out in their default animation, facing in a random
	# direction

	var dir = Globals.get_random_direction()
	direction = dir.normalized()
	$AnimationTree[idle_blend_param] = dir
	state_machine.travel(default_anim)
	is_running = false

	# set up the timer for updating movements

	timer = Timer.new()
	add_child(timer)
	timer.one_shot = true
	timer.connect("timeout", self, "_on_timer_timeout")
	_init_timer()

#
# Called once to set the animation timer the first time. May be overridden by
# each character subclass.
#
func _init_timer():
	timer.start(2 + 3 * randf())

#
# Called when the animation timer times out, to update the character's animation
# state. May be overridden by each character subclass.
#
func _on_timer_timeout():

	# running => stop and idle for 2-5 seconds

	if is_running:
		$AnimationTree[idle_blend_param] = $AnimationTree[run_blend_param]
		state_machine.travel(default_anim)
		is_running = false

	# not running => start running for 2-5 seconds

	else:
		$AnimationTree[run_blend_param] = $AnimationTree[idle_blend_param]
		state_machine.travel(run_anim)
		is_running = true

	timer.start(2 + 3 * randf())

func _physics_process(_delta):
	if state_machine.get_current_node() == run_anim:
		var time_scale = $AnimationTree[run_time_param]
		if time_scale != 0:
			var dir = move_and_slide(direction * speed * time_scale)
			if get_slide_count() > 0:
				dir = Globals.get_nearest_direction(dir)
				$AnimationTree[run_blend_param] = dir
				direction = dir.normalized()

func set_time_scale(scale = 1.0):
	$AnimationTree[idle_time_param] = scale
	$AnimationTree[run_time_param] = scale

func freeze(flash=true):
	set_time_scale(0)
	if flash:
		$Flasher.play("flash")

func unfreeze(flash=true):
	set_time_scale(1)
	if flash:
		$Flasher.play("flash")

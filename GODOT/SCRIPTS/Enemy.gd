extends KinematicBody2D

export var char_name: String
export var speed := Vector2(100, 50)
export var default_anim := "Idle"
export var run_anim := "Run"

var idle_blend_param: String
var run_blend_param: String
var idle_time_param: String
var run_time_param: String
var timer: Timer
var is_running := false
var state_machine: AnimationNodeStateMachinePlayback
var direction: Vector2

func _ready():
	$AnimationTree.active = true
	state_machine = $AnimationTree["parameters/playback"]

	idle_blend_param = "parameters/%s/BlendSpace2D/blend_position" % default_anim
	run_blend_param = "parameters/%s/BlendSpace2D/blend_position" % run_anim
	idle_time_param = "parameters/%s/TimeScale/scale" % default_anim
	run_time_param = "parameters/%s/TimeScale/scale" % run_anim

	timer = Timer.new()
	add_child(timer)
	timer.one_shot = true
	timer.connect("timeout", self, "_on_timer_timeout")
	timer.start(3 * randf())

	var dir = Globals.get_random_direction()
	direction = dir.normalized()

	if randf() < 0.5:
		$AnimationTree[idle_blend_param] = dir
		state_machine.travel(default_anim)
	else:
		$AnimationTree[run_blend_param] = dir
		state_machine.travel(run_anim)

func _on_timer_timeout():
	if is_running:
		$AnimationTree[idle_blend_param] = $AnimationTree[run_blend_param]
		state_machine.travel(default_anim)
	else:
		$AnimationTree[run_blend_param] = $AnimationTree[idle_blend_param]
		state_machine.travel(run_anim)
	is_running = not is_running
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

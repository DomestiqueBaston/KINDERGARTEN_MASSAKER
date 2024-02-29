tool
extends Enemy

# probability of vomiting when done running, if there is no obstacle
export var vomit_chances := 0.667

signal vomit

onready var vomit_length = $AnimationPlayer.get_animation("00_Vomit").length
var vomit_obstacle_count := 0

func on_timer_timeout():

	# not running => start running for 2-5 seconds

	if not is_running:
		$CyclePlayer.play(run_anim)
		timer.start(rand_range(2, 5) / $CyclePlayer.get_speed())
		is_running = true

	# finished running, no obstacle, and lucky roll of the dice => vomit, then
	# start running again at the end of the vomit animation

	elif vomit_obstacle_count == 0 and randf() < vomit_chances:
		$CyclePlayer.play("Vomit", true)
		$CyclePlayer.play(run_anim)
		$AnimationPlayer.advance(0)  # to update Point_of_Vomit_Spawn
		emit_signal("vomit", $Point_of_Vomit_Spawn.global_position)
		timer.start(
			(vomit_length + rand_range(2, 5)) / $CyclePlayer.get_speed())
		# when the timer goes off, he will be running...
		is_running = true

	# otherwise => idle 1-3 seconds

	else:
		$CyclePlayer.play(default_anim)
		timer.start(rand_range(1, 3) / $CyclePlayer.get_speed())
		is_running = false

func _on_Bg_Collider_for_Vomit_Spill_body_entered(body: Node):
	if body.is_class("StaticBody2D"):
		#print("new obstacle: %s (%s)" % [body.name, body.get_class()])
		vomit_obstacle_count += 1

func _on_Bg_Collider_for_Vomit_Spill_body_exited(body: Node):
	if body.is_class("StaticBody2D"):
		vomit_obstacle_count -= 1

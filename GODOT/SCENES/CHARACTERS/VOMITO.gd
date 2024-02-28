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
		var time_to_wait = 2 + 3 * randf()

		# When vomiting, we set the timer above to go off during the Vomit
		# cycle, to ensure that play("Run") is called before the cycle ends.
		# The transition to Run won't happen until the end of the Vomit cycle,
		# so we have to add to the timer however much time is remaining in the
		# cycle.

		if "Vomit" in $AnimationPlayer.current_animation:
			time_to_wait += (
				vomit_length - $AnimationPlayer.current_animation_position)

		timer.start(time_to_wait / $CyclePlayer.get_speed())

	# finished running, no obstacle, and lucky roll of the dice => vomit, then
	# start running again at the end of the vomit animation

	elif vomit_obstacle_count == 0 and randf() < vomit_chances:
		$CyclePlayer.play("Vomit", true)
		$AnimationPlayer.advance(0)  # to update Point_of_Vomit_Spawn
		emit_signal("vomit", $Point_of_Vomit_Spawn.global_position)
		timer.start(vomit_length * 0.5 / $CyclePlayer.get_speed())

	# otherwise => idle 1-3 seconds

	else:
		$CyclePlayer.play(default_anim)
		timer.start((1 + 2 * randf()) / $CyclePlayer.get_speed())

	is_running = not is_running

func _on_Bg_Collider_for_Vomit_Spill_body_entered(body: Node):
	if body.is_class("StaticBody2D"):
		#print("new obstacle: %s (%s)" % [body.name, body.get_class()])
		vomit_obstacle_count += 1

func _on_Bg_Collider_for_Vomit_Spill_body_exited(body: Node):
	if body.is_class("StaticBody2D"):
		vomit_obstacle_count -= 1

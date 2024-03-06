tool
extends Enemy

# probability of vomiting when done running, if there is no obstacle
export var vomit_chances := 0.667

signal vomit

var vomit_length: float
var vomit_obstacle_count := 0

func _ready():
	if not Engine.editor_hint:
		vomit_length = $AnimationPlayer.get_animation("00_Vomit").length

func on_timer_timeout():

	# not running => start running for 2-5 seconds

	if not $AnimationPlayer.current_animation.ends_with("_Run"):
		$CyclePlayer.play("Run")
		start_timer(rand_range(2, 5))

	# finished running, no obstacle, and lucky roll of the dice => vomit, then
	# start running again at the end of the vomit animation

	elif vomit_obstacle_count == 0 and randf() < vomit_chances:
		$CyclePlayer.play("Vomit", true)
		$CyclePlayer.play("Run")
		$AnimationPlayer.advance(0)  # to update Point_of_Vomit_Spawn
		emit_signal("vomit", $Point_of_Vomit_Spawn.global_position)
		start_timer(vomit_length + rand_range(2, 5))

	# otherwise => idle 1-3 seconds

	else:
		$CyclePlayer.play(default_anim)
		start_timer(rand_range(1, 3))

func _on_Bg_Collider_for_Vomit_Spill_body_entered(body: Node):
	if body.is_class("StaticBody2D"):
		vomit_obstacle_count += 1

func _on_Bg_Collider_for_Vomit_Spill_body_exited(body: Node):
	if body.is_class("StaticBody2D"):
		vomit_obstacle_count -= 1

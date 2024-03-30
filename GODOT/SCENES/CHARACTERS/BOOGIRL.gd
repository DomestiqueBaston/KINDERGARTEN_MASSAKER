tool
extends Attacker

# speed at which booger projectile travels
export var projectile_speed := 200.0

# booger projectile
var projectile_scene = preload("res://SCENES/FX/Booger.tscn")

# booger explosion
var explosion_scene = preload("res://SCENES/FX/Booger_Smoke.tscn")

# list of projectiles that have been created and are still moving
var projectiles: Array

#
# When the Boogirl is deleted, there may be some projectiles which have not
# been cleaned up yet. They have to be deleted explicitly, since they are not
# parented to the Boogirl.
#
func _exit_tree():
	if Engine.editor_hint:
		return
	for projectile in projectiles:
		projectile.queue_free()
	projectiles.clear()

#
# Called a short time after throwing to create a projectile aimed at the
# alien. The projectile is added to this node's PARENT, so that it can be
# moved independently.
#
func _create_projectile():
	if not attack_allowed or alien == null:
		return
	var pos = $Point_of_Booger_Spawn.global_position
	var target = alien.get_hit_target()
	var inst = projectile_scene.instance()
	inst.velocity = Globals.get_persp_velocity(
		pos, target, projectile_speed * rand_range(0.9, 1.1))
	inst.position = pos
	inst.time_scale = $CyclePlayer.get_speed()

	# if the alien is closer than the distance a booger normally travels,
	# speed up the booger animation cycle so that it ends sooner (that's what
	# triggers the "done" signal)

	var anim_player = inst.get_node("AnimationPlayer")
	if anim_player.autoplay:
		var duration = anim_player.get_animation(anim_player.autoplay).length
		var max_dist = projectile_speed * duration
		var actual_dist = sqrt(Globals.get_persp_dist_squared(pos, target))
		actual_dist = clamp(actual_dist, max_dist/2, max_dist)
		inst.playback_speed = max_dist / actual_dist

	inst.connect("hit", self, "_destroy_booger", [inst])
	get_parent().add_child(inst)
	projectiles.append(inst)
	inst.connect("done", self, "_booger_landed", [inst])

#
# Called when a booger has reached the end of its animation. The booger is
# destroyed and an explosion is created.
#
func _booger_landed(booger: Node2D):
	var inst = explosion_scene.instance()
	inst.position = booger.position
	inst.set_time_scale($CyclePlayer.get_speed())
	get_parent().add_child(inst)
	projectiles.append(inst)
	inst.connect("hit", self, "_on_explosion_hit")
	inst.connect("done", self, "_destroy_projectile", [inst])
	_destroy_projectile(booger)

func _destroy_booger(projectile: Node2D):
	_destroy_projectile(projectile)

func _destroy_projectile(projectile: Node2D):
	projectiles.erase(projectile)
	projectile.queue_free()

func _on_explosion_hit():
	hit_count += 1

#
# Overrides the method from Enemy to change the time scale for projectiles as
# well.
#
func set_time_scale(scale: float):
	for booger in projectiles:
		booger.set_time_scale(scale)
	.set_time_scale(scale)

#
# Overrides the method from Enemy to pause the animation and displacement of
# projectiles as well.
#
func stop_time():
	for booger in projectiles:
		booger.pause()
	.stop_time()

#
# Overrides the method from Enemy to resume the animation and displacement of
# projectiles as well.
#
func restart_time():
	for booger in projectiles:
		booger.resume()
	.restart_time()

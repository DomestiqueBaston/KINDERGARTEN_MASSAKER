tool
extends Attacker

# speed at which spit projectile travels
export var projectile_speed := 200.0

# spit projectile
var projectile_scene = preload("res://SCENES/FX/Spit.tscn")

# list of projectiles that have been created and are still moving
var projectiles: Array

#
# When the Cracheuse is deleted, there may be some projectiles which have not
# been cleaned up yet. They have to be deleted explicitly, since they are not
# parented to the Cracheuse.
#
func _exit_tree():
	for projectile in projectiles:
		projectile.queue_free()
	projectiles.clear()

#
# When the Spit animation cycle begins, wait a couple frames before creating a
# projectile.
#
func _on_animation_started(anim_name):
	if attack_allowed and anim_name.ends_with("_Spit"):
		$Projectile_Timer.start()

#
# Called a short time after spitting to create a projectile aimed at the
# alien. The projectile is added to this node's PARENT, so that it can be
# moved independently.
#
func _create_projectile():
	if not attack_allowed or alien == null:
		return
	var pos = $Point_of_Spit_Spawn.global_position
	var target = alien.get_hit_target()
	var inst = projectile_scene.instance()
	inst.velocity = Globals.get_persp_velocity(
		pos, target, projectile_speed * rand_range(0.9, 1.1))
	inst.position = pos
	inst.time_scale = $CyclePlayer.get_speed()
	inst.connect("hit", self, "_on_projectile_hit", [inst])
	get_parent().add_child(inst)
	projectiles.append(inst)
	inst.connect("done", self, "_destroy_projectile", [inst])

#
# Called when a projectile has reached the end of its animation (without
# hitting the alien). The projectile is destroyed.
#
func _destroy_projectile(_anim_name: String, projectile: Node2D):
	projectiles.erase(projectile)
	projectile.queue_free()

#
# Called when a projectile has hit the alien. The number of hits is incremented
# and the projectile is destroyed.
#
func _on_projectile_hit(projectile: Node2D):
	hit_count += 1
	projectiles.erase(projectile)
	projectile.queue_free()

#
# Overrides the method from Enemy to change the time scale for projectiles as
# well.
#
func set_time_scale(scale: float):
	if $Projectile_Timer.time_left > 0:
		var prev_scale = $CyclePlayer.get_speed()
		$Projectile_Timer.start(
			$Projectile_Timer.time_left * (prev_scale / scale))
	for spit in projectiles:
		spit.set_time_scale(scale)
	.set_time_scale(scale)

#
# Overrides the method from Enemy to pause the animation and displacement of
# projectiles as well.
#
func stop_time():
	$Projectile_Timer.set_paused(true)
	for spit in projectiles:
		spit.pause()
	.stop_time()

#
# Overrides the method from Enemy to resume the animation and displacement of
# projectiles as well.
#
func restart_time():
	$Projectile_Timer.set_paused(false)
	for spit in projectiles:
		spit.resume()
	.restart_time()

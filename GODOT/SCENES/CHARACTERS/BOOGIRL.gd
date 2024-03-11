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
	for projectile in projectiles:
		projectile.queue_free()
	projectiles.clear()

#
# When the Booger animation cycle begins, wait a few frames before creating a
# projectile.
#
func _on_animation_started(anim_name):
	if attack_allowed and anim_name.ends_with("_Booger"):
		$Projectile_Timer.start()

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
	if $Projectile_Timer.time_left > 0:
		var prev_scale = $CyclePlayer.get_speed()
		$Projectile_Timer.start(
			$Projectile_Timer.time_left * (prev_scale / scale))
	for booger in projectiles:
		booger.set_time_scale(scale)
	.set_time_scale(scale)

#
# Overrides the method from Enemy to pause the animation and displacement of
# projectiles as well.
#
func stop_time():
	$Projectile_Timer.set_paused(true)
	for booger in projectiles:
		booger.pause()
	.stop_time()

#
# Overrides the method from Enemy to resume the animation and displacement of
# projectiles as well.
#
func restart_time():
	$Projectile_Timer.set_paused(false)
	for booger in projectiles:
		booger.resume()
	.restart_time()

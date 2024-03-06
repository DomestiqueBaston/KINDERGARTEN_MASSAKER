extends Enemy

# speed at which spit projectile travels
export var spit_speed := 200.0

# length in seconds of the Spit animation
onready var spit_length = $AnimationPlayer.get_animation("00_Spit").length

# spit projectile
var projectile_scene = preload("res://SCENES/FX/Spit.tscn")

# list of projectiles that have been created and are still moving
var projectiles: Array

# if false, spitting is not allowed until the Cracheuse stops to idle
var spit_allowed := true

# how many projectiles the alien has been hit with on the current attack
var hit_count: int

#
# When the Cracheuse is deleted, there may be some projectiles which have not
# been cleaned up yet. They have to be deleted explicitly, since they are not
# parented to the Cracheuse.
#
func _exit_tree():
	for projectile in projectiles:
		projectile.queue_free()

func on_timer_timeout():
	if $AnimationPlayer.current_animation.ends_with("_Run"):
		spit_allowed = true
		$CyclePlayer.play(default_anim)
		start_timer(rand_range(2, 5))
	else:
		_start_running()

#
# Plays the Run animation cycle 2-5 seconds plus any extra_wait time.
#
func _start_running(extra_wait := 0.0):
	$CyclePlayer.play("Run")
	start_timer(extra_wait + rand_range(2, 5))

#
# Stops attacking (at the end of the Spit animation cycle), turns around and
# runs in the opposite direction.
#
func _stop_spitting():
	spit_allowed = false
	turn_around()
	var extra_wait := 0.0
	if $AnimationPlayer.current_animation.ends_with("_Spit"):
		extra_wait = spit_length - $AnimationPlayer.current_animation_position
	_start_running(extra_wait)

#
# Called by _physics_process().
#
func tick(delta):
	if Engine.editor_hint or $CyclePlayer.is_paused():
		return

	# can't see the alien => run at random like any other character

	if not is_alien_visible():
		.tick(delta)

	# run towards the alien and stop to attack him when close enough

	elif $AnimationPlayer.current_animation.ends_with("_Run"):
		var attack = false
		if spit_allowed:
			face_alien()
			if is_alien_in_range():
				attack = true
		if attack:
			stop_timer()
			hit_count = 0
			$CyclePlayer.play("Spit", true)
		else:
			.tick(delta)

	# spitting => just turn to face the alien

	elif $AnimationPlayer.current_animation.ends_with("_Spit"):
		if spit_allowed:
			face_alien()

#
# When the Spit animation cycle begins, wait a couple frames before creating a
# projectile.
#
func _on_animation_started(anim_name):
	if spit_allowed and anim_name.ends_with("_Spit"):
		$Projectile_Timer.start()

#
# Called a short timer after spitting to create a projectile aimed at the
# alien. The projectile is added to this node's PARENT, so that it can be
# moved independently.
#
func _create_projectile():
	var pos = $Point_of_Spit_Spawn.global_position
	var target = alien.get_hit_target()
	var inst = projectile_scene.instance()
	inst.velocity = (target - pos).normalized() * spit_speed
	inst.position = pos
	inst.connect("hit", self, "_on_hit", [inst])
	get_parent().add_child(inst)
	projectiles.append(inst)
	var anim_player = inst.get_node("AnimationPlayer")
	anim_player.connect(
		"animation_finished", self, "_destroy_projectile", [inst])
	anim_player.play("Spit")

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
func _on_hit(projectile: Node2D):
	hit_count += 1
	if spit_allowed and hit_count >= 3:
		_stop_spitting()
	projectiles.erase(projectile)
	projectile.queue_free()

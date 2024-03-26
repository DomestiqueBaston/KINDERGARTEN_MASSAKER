tool
extends Enemy
class_name Attacker

# Enemy subclass for kids who attack the alien, then get bored and go away after
# hitting him a certain number of times.

# what weapon the attacker attacks with
export(Globals.Weapon) var weapon_type = Globals.Weapon.NONE

# number of successful hits before we get bored and go away
export var max_hit_count := 3

# minimum amount of time spent in the default animation cycle before moving
export var min_idle_time := 2.0

# maximum amount of time spent in the default animation cycle before moving
export var max_idle_time := 5.0

# chances the enemy will spot the alien and chase him even when idling
export var spot_alien_on_idle_chances := 0.0

# length in seconds of the attack animation
var attack_length: float

# are we allowed to attack if we see the alien and get close enough?
var attack_allowed := true

# number of hits in the current attack
var hit_count := 0

func _ready():
	if Engine.editor_hint:
		return
	var anim_name = "00_" + attack_animation
	attack_length = $AnimationPlayer.get_animation(anim_name).length

func on_timer_timeout():
	if $CyclePlayer.get_current_animation() == "Run":
		$CyclePlayer.play(default_animation)
		start_timer(rand_range(min_idle_time, max_idle_time))
	else:
		_start_running()
		attack_allowed = true

#
# Play the Run animation cycle 2-5 seconds plus any extra_wait time.
#
func _start_running(extra_wait := 0.0):
	$CyclePlayer.play("Run")
	start_timer(extra_wait + rand_range(2, 5))

#
# Stop attacking (at the end of the animation cycle) and start running again. If
# and_go_away is true, turn around and don't attack again until the next Run
# cycle ends.
#
func _stop_attacking(and_go_away: bool):
	if and_go_away:
		turn_around()
		attack_allowed = false
	var extra_wait := 0.0
	if $CyclePlayer.get_current_animation() == attack_animation:
		extra_wait = attack_length - $AnimationPlayer.current_animation_position
	_start_running(extra_wait)

#
# Called by _physics_process().
#
func tick(delta):
	if is_repulsed():
		.tick(delta)

	if $CyclePlayer.is_paused():
		return

	# run towards the alien and stop to attack him when close enough

	if $CyclePlayer.get_current_animation() == "Run" and not is_repulsed():
		var attack_him = false
		if attack_allowed:
			face_alien()
			if is_alien_visible() and is_alien_in_range():
				attack_him = true
		if attack_him:
			hit_count = 0
			$CyclePlayer.play(attack_animation, true)
			# keep attacking until we have a reason to stop (see below)
			stop_timer()
		else:
			.tick(delta)

	# stop attacking after some number of hits, or if the alien is no no longer
	# visible and in range

	elif $CyclePlayer.get_current_animation() == attack_animation:
		if attack_allowed:
			face_alien()
			if not (hit_count < max_hit_count
					and is_alien_visible()
					and is_alien_in_range()):
				_stop_attacking(hit_count >= max_hit_count)

#
# If the alien becomes visible while the enemy is idling, the enemy may wake up
# and start chasing him.
#
func alien_seen():
	if ($CyclePlayer.get_current_animation() == default_animation
		and randf() < spot_alien_on_idle_chances):
		_start_running()

#
# Don't try to get around the alien; just stop when he is reached.
#
func want_to_avoid_collider(collider: Object) -> bool:
	return collider.name != "ALIEN"

#
# Called when an attack hits the alien. A subclass that strikes the alien
# directly, rather than with projectiles, will connect its attack collider's
# area_entered() signal to this.
#
func _on_hit(_area: Area2D):
	hit_count += 1

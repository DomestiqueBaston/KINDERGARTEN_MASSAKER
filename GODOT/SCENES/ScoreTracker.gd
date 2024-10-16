extends Node

var last_score := 0.0
var start_time := 0

func start_game():
	start_time = Time.get_ticks_msec()
	$Timer.start()

func stop_game():
	$Timer.stop()
	last_score = get_current_score()
	Settings.set_best_score(max(Settings.get_best_score(), last_score))

func is_playing() -> bool:
	return not $Timer.is_stopped()

func get_current_score() -> float:
	return (Time.get_ticks_msec() - start_time) / 1000.0

func get_last_score() -> float:
	return last_score

func _on_timeout():
	var new_unlocked = int(get_current_score() / 15.0)
	var old_unlocked = int(Settings.get_best_score() / 15.0)
	if new_unlocked > old_unlocked and new_unlocked <= 4:
		$AudioStreamPlayer.play()

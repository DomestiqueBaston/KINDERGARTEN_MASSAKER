extends Node

var best_score = 0.0
var unlocked_talents = 0
var last_score = 0.0
var start_time = 0

func start_game():
	start_time = Time.get_ticks_msec()
	$Timer.start()

func stop_game():
	$Timer.stop()
	last_score = get_current_score()
	best_score = max(best_score, last_score)

func is_playing() -> bool:
	return not $Timer.is_stopped()

func get_current_score() -> float:
	return (Time.get_ticks_msec() - start_time) / 1000.0

func get_best_score() -> float:
	return best_score

func get_last_score() -> float:
	return last_score

func _on_timeout():
	var unlocked = int(get_current_score() / 15.0)
	if unlocked_talents < unlocked and unlocked <= 4:
		unlocked_talents = unlocked
		$AudioStreamPlayer.play()

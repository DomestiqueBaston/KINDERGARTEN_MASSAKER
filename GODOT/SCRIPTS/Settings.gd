extends Node

var _ambient_volume := 5
var _music_volume := 5
var _effects_volume := 5
var _best_score := 0.0
var _watched_dialogue := false

const options_path = "user://settings.cfg"

func _ready():
	load_settings()

func load_settings():
	var config = ConfigFile.new()
	if config.load(options_path) == OK:
		set_ambient_volume(config.get_value("settings", "ambient_volume", 5))
		set_music_volume(config.get_value("settings", "music_volume", 5))
		set_effects_volume(config.get_value("settings", "effects_volume", 5))
		_best_score = config.get_value("history", "best_score", 0.0)
		_watched_dialogue = config.get_value(
			"history", "watched_dialogue", false)
	else:
		set_ambient_volume(5)
		set_music_volume(5)
		set_effects_volume(5)
		_best_score = 0.0
		_watched_dialogue = false

func save_settings():
	var config = ConfigFile.new()
	config.set_value("settings", "ambient_volume", _ambient_volume)
	config.set_value("settings", "music_volume", _music_volume)
	config.set_value("settings", "effects_volume", _effects_volume)
	config.set_value("history", "best_score", _best_score)
	config.set_value("history", "watched_dialogue", _watched_dialogue)
	config.save(options_path)

func get_ambient_volume():
	return _ambient_volume

func set_ambient_volume(volume):
	_ambient_volume = volume
	var bus = AudioServer.get_bus_index("AMBIANCE")
	AudioServer.set_bus_volume_db(bus, _volume_to_db(volume))

func get_music_volume():
	return _music_volume

func set_music_volume(volume):
	_music_volume = volume
	var bus = AudioServer.get_bus_index("MUSIC")
	AudioServer.set_bus_volume_db(bus, _volume_to_db(volume))

func get_effects_volume():
	return _effects_volume

func set_effects_volume(volume):
	_effects_volume = volume
	var bus = AudioServer.get_bus_index("FX")
	AudioServer.set_bus_volume_db(bus, _volume_to_db(volume))

func _volume_to_db(volume):
	if volume < 5:
		return -80
	elif volume < 10:
		return -10
	else:
		return 0

func get_best_score() -> float:
	return _best_score

func set_best_score(score: float):
	_best_score = score

func get_watched_dialogue() -> bool:
	return _watched_dialogue

func set_watched_dialogue(watched: bool):
	_watched_dialogue = watched

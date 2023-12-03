extends Node

var ambient_volume = 5
var music_volume = 5
var effects_volume = 5

const options_path = "user://settings.cfg"

func _ready():
	load_settings()

func load_settings():
	var config = ConfigFile.new()
	if config.load(options_path) == OK:
		set_ambient_volume(config.get_value("settings", "ambient_volume", 5))
		set_music_volume(config.get_value("settings", "music_volume", 5))
		set_effects_volume(config.get_value("settings", "effects_volume", 5))
	else:
		set_ambient_volume(5)
		set_music_volume(5)
		set_effects_volume(5)

func save_settings():
	var config = ConfigFile.new()
	config.set_value("settings", "ambient_volume", ambient_volume)
	config.set_value("settings", "music_volume", music_volume)
	config.set_value("settings", "effects_volume", effects_volume)
	config.save(options_path)

func get_ambient_volume():
	return ambient_volume

func set_ambient_volume(volume):
	ambient_volume = volume
	var bus = AudioServer.get_bus_index("AMBIANCE")
	AudioServer.set_bus_volume_db(bus, _volume_to_db(volume))

func get_music_volume():
	return music_volume

func set_music_volume(volume):
	music_volume = volume
	var bus = AudioServer.get_bus_index("MUSIC")
	AudioServer.set_bus_volume_db(bus, _volume_to_db(volume))

func get_effects_volume():
	return effects_volume

func set_effects_volume(volume):
	effects_volume = volume
	var bus = AudioServer.get_bus_index("FX")
	AudioServer.set_bus_volume_db(bus, _volume_to_db(volume))

func _volume_to_db(volume):
	if volume < 5:
		return -80
	elif volume < 10:
		return -10
	else:
		return 0

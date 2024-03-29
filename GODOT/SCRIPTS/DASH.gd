extends Node2D

# maximum number of points in the trail at any given time
export var max_point_count = 100

# signal emitted when dash ends
signal done

var running := false

#
# Turns on dash for the given amount of time in seconds.
#
func start(duration: float):
	$Dash_Trail.show()
	$FX.play()
	$Dash_Timer.start(duration)
	running = true

#
# Interrupts dash if it is on. Does nothing otherwise.
#
func stop():
	$Dash_Timer.stop()
	_reset()

func _on_Dash_Timer_timeout():
	_reset()
	emit_signal("done")

func _reset():
	$Dash_Trail.hide()
	$Dash_Trail.clear_points()
	running = false

#
# Returns true if dash is on.
#
func is_running() -> bool:
	return running

#
# Adds a point to the dash trail, if dash is on.
#
func add_point_to_trail(point: Vector2):
	if is_running():
		$Dash_Trail.add_point(point)
		while $Dash_Trail.get_point_count() > max_point_count:
			$Dash_Trail.remove_point(0)

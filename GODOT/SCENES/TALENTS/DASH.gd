extends Node

export var max_point_count = 100

func start():
	$Dash_Trail.show()
	$FX.play()

func stop():
	$Dash_Trail.hide()
	$Dash_Trail.clear_points()

func is_running() -> bool:
	return $Dash_Trail.visible

func add_point_to_trail(point: Vector2):
	if is_running():
		$Dash_Trail.add_point(point)
		while $Dash_Trail.get_point_count() > max_point_count:
			$Dash_Trail.remove_point(0)

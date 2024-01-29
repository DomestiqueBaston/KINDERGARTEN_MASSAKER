# Adapté de : https://www.youtube.com/watch?v=acR5VKM0d3I
extends Line2D


var length = 15
var point = Vector2()


func _process(_delta):
	global_position = Vector2(0, 0)
	global_rotation = 0
	point = $"../..".global_position
	add_point(point)
	while get_point_count() > length:
		remove_point(0)

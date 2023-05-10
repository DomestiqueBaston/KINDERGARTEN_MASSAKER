extends KinematicBody2D

export(int) var speed = 150.0
var direction = Vector2.ZERO

# Ca marche bizarre. La caméra bouge puis s'arrête (c'est du au clavier car avec la manette, c'est bon) et en bout de course (sur les bords de la map), les shaders continuent de se déplacer alors qu'ils sont fils de la caméra et que le script est sur le père de la caméra...

func _process(_delta: float) -> void:
# warning-ignore:return_value_discarded
	#direction = direction.normalized() #Le normalized ne fonctionne pas...
	move_and_slide(direction * speed)
	
func _input(event: InputEvent) -> void:
	direction.x = int(event.is_action_pressed("ui_right")) - int(event.is_action_pressed("ui_left"))
	direction.y = int(event.is_action_pressed("ui_down")) - int(event.is_action_pressed("ui_up"))


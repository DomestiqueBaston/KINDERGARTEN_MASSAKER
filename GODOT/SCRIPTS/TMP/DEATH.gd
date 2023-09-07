extends Node2D


func _ready():
	if Autoload.elapsed_time > Autoload.best_time:
		Autoload.best_time = Autoload.elapsed_time
	$Tot_in_STYLE.text = " Tot in \n" + str(stepify(Autoload.elapsed_time, 0.1)) + " sEkundeN!"
	$Tot_in_TEXTURE.text = " Tot in \n" + str(stepify(Autoload.elapsed_time, 0.1)) + " sEkundeN!"
	$BESTE_STYLE.text = "Beste: " + str(stepify(Autoload.best_time, 0.1)) + "''"
	$BESTE_TEXTURE.text = "Beste: " + str(stepify(Autoload.best_time, 0.1)) + "''"

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		Autoload.restart_game = true 

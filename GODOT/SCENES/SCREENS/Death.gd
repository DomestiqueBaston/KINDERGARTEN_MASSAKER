extends Node2D

export var elapsed_time = 0.0
export var best_time = 0.0

func _ready():
	$Tot_in_STYLE.text = " Tot in \n%1.0f sEkundeN!" % elapsed_time
	$Tot_in_TEXTURE.text = $Tot_in_STYLE.text
	$BESTE_STYLE.text = "Beste: %1.0f''" % best_time
	$BESTE_TEXTURE.text = $BESTE_STYLE.text

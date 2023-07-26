extends Sprite

onready var animationPlayer = $AnimationPlayer
export var animation = "Slide"

func _ready():
	var img = get_viewport().get_texture().get_data()
	img.flip_y()
	var screenshot = ImageTexture.new()
	screenshot.create_from_image(img)
	texture = screenshot
	animationPlayer.play(animation)

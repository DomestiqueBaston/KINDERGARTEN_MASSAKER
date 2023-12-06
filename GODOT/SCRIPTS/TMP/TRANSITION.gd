extends Sprite

func take_screenshot():
	var img = get_viewport().get_texture().get_data()
	img.flip_y()
	var screenshot = ImageTexture.new()
	screenshot.create_from_image(img)
	texture = screenshot
	# ensure that texture is made invisible immediately, rather than waiting
	# for the animation to start...
	$"../AnimationPlayer".advance(0)
	$"../AnimationPlayer".play("Fade")

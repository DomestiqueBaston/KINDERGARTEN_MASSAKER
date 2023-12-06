extends Sprite

func take_screenshot():
	var img = get_viewport().get_texture().get_data()
	img.flip_y()
	var screenshot = ImageTexture.new()
	screenshot.create_from_image(img)
	texture = screenshot
	$"../AnimationPlayer".play("Fade")

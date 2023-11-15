extends Sprite

onready var animationPlayer = $"../AnimationPlayer"
export var animation = "Fade"

func take_screenshot():
	var img = get_viewport().get_texture().get_data()
	img.flip_y()
	var screenshot = ImageTexture.new()
	screenshot.create_from_image(img)
	texture = screenshot
	animationPlayer.play("Fade")

func _on_AnimationPlayer_animation_finished(_anim_name):
	Autoload.transition_signal = true

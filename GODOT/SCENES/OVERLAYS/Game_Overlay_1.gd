extends CanvasLayer

func start_animation():
	var rand = randi()
	if rand & 0x1:
		$Aberration_pos.play("aberration")
	else:
		$Aberration_neg.play("aberration")
	if rand & 0x2:
		$Brightness_pos.play("brightness")
	else:
		$Brightness_neg.play("brightness")
	if rand & 0x4:
		$Saturation_pos.play("saturation")
	else:
		$Saturation_neg.play("saturation")
	if rand & 0x8:
		$Contrast_pos.play("contrast")
	else:
		$Contrast_neg.play("contrast")
	$General.play("general")

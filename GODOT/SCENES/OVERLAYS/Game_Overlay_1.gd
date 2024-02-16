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

func rewind_animation():
	$Aberration_pos.seek(0)
	$Aberration_neg.seek(0)
	$Brightness_pos.seek(0)
	$Brightness_neg.seek(0)
	$Saturation_pos.seek(0)
	$Saturation_neg.seek(0)
	$Contrast_pos.seek(0)
	$Contrast_neg.seek(0)
	$General.seek(0)

func reset_animation():
	$Aberration_pos.play("RESET")
	$Aberration_neg.play("RESET")
	$Brightness_pos.play("RESET")
	$Brightness_neg.play("RESET")
	$Saturation_pos.play("RESET")
	$Saturation_neg.play("RESET")
	$Contrast_pos.play("RESET")
	$Contrast_neg.play("RESET")
	$General.play("RESET")

extends CanvasLayer

var aberration_player: AnimationPlayer
var brightness_player: AnimationPlayer
var saturation_player: AnimationPlayer
var contrast_player: AnimationPlayer

func start_animation():
	var rand = randi()
	aberration_player = $Aberration_pos if rand & 0x1 else $Aberration_neg
	brightness_player = $Brightness_pos if rand & 0x2 else $Brightness_neg
	saturation_player = $Saturation_pos if rand & 0x4 else $Saturation_neg
	contrast_player   = $Contrast_pos   if rand & 0x8 else $Contrast_neg
	aberration_player.play("aberration")
	brightness_player.play("brightness")
	saturation_player.play("saturation")
	contrast_player.play("contrast")
	$General.play("general")

func rewind_animation():
	aberration_player.seek(0)
	brightness_player.seek(0)
	saturation_player.seek(0)
	contrast_player.seek(0)
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

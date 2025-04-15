extends Area3D

var tweener
func _ready() -> void:
	$Sprite3D.frame_coords.y = randi_range(0, 4)
	MusicNode.on_beat.connect(beat)

func beat() -> void:
	if tweener:
		tweener.kill()
	tweener = create_tween()
	tweener.tween_property($Sprite3D, "scale", Vector3(1.5, 1.5, 1.5), 0.15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tweener.tween_property($Sprite3D, "scale", Vector3.ONE, 0.15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)

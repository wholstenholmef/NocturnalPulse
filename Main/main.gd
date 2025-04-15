extends Node3D

var in_tutorial = false

func _ready() -> void:
	%ControlLayer.hide()

func _on_play_button_pressed() -> void:
	if in_tutorial:
		return
	%ControlLayer.show()
	MusicNode.play_ost(randi_range(0,1))
	get_tree().get_first_node_in_group("Player").exit_intro()
	var tweener = create_tween()
	tweener.tween_property(%contentControl, "modulate:a", 0, 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)

func _on_tutorial_button_pressed() -> void:
	%tutorialAnimationPlayer.play("show_tutorial")
	in_tutorial = true

func _physics_process(delta: float) -> void:
	if in_tutorial:
		if Input.is_anything_pressed():
			%tutorialAnimationPlayer.play("close_tutorial")
			in_tutorial = false

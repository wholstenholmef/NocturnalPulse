extends CanvasLayer

func _ready() -> void:
	hide()
	if OS.get_name() != "Android":
		%gyroButton.hide()

func _on_pause_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		get_tree().call_deferred("set_pause", true)
		%pauseAnimationPlayer.play("open_pause_menu")
		show()
	else:
		%pauseAnimationPlayer.play("close_pause_menu")
		get_tree().call_deferred("set_pause", false)
		await %pauseAnimationPlayer.animation_finished
		hide()

func _on_resumir_button_pressed() -> void:
	%pauseAnimationPlayer.play("close_pause_menu")
	get_tree().call_deferred("set_pause", false)
	%pauseButton.set_pressed_no_signal(false)

func _on_reiniciar_button_pressed() -> void:
	%pauseAnimationPlayer.play("close_pause_menu")
	await  %pauseAnimationPlayer.animation_finished
	get_tree().call_deferred("set_pause", false)
	get_tree().change_scene_to_file("res://Main/Main.tscn")
	%pauseButton.set_pressed_no_signal(false)

func _on_gyro_button_toggled(toggled_on: bool) -> void:
	get_tree().get_first_node_in_group("Player").set_gyro(toggled_on)
	if toggled_on:
		%gyroButton.text = "Gyro: ON"
	else:
		%gyroButton.text = "Gyro: OFF"

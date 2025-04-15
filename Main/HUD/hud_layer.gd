extends CanvasLayer

var player_node : Player

var pickup_effect = preload("res://Main/PickUp/PickUpEffect/PickUpEffect.tscn")
var pickup_marker_position : Vector2

var default_pickup_label_position
var pickup_label_tweener 

var head_tweener 

func _ready() -> void:
	player_node = get_node_or_null("../")
	%distanceLabel.text = "[wave amp=30 freq=5 connected=0]\n"
	await get_tree().process_frame
	pickup_marker_position = Vector2(280, 140)
	default_pickup_label_position = Vector2(260, 140)

func _physics_process(delta: float) -> void:
	#%distanceLabel.remove_paragraph()
	%distanceLabel.newline()
	%distanceLabel.append_text(str(int(abs(round(player_node.global_position.z)))) + " mts.")
	%distanceLabel.remove_paragraph(1)
	#%distanceLabel.text = "[wave] %d mts." % abs(round(player_node.global_position.z))
	#%distanceLabel.text = "[center][wave]" + str(abs(round(player_node.global_position.z))) + " mts."
	

func on_pickup(pickup_position := Vector3.ZERO, pickup_counter : int = 0, pickup_sprite_frame := 0) -> void:
	if pickup_label_tweener:
		pickup_label_tweener.kill()
	pickup_label_tweener = create_tween()
	pickup_label_tweener.tween_property(%pickupCounterLabel, "position:y", -8, 0.5).as_relative().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	pickup_label_tweener.tween_property(%pickupCounterLabel, "position:y", default_pickup_label_position.y, 0.3).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	%pickupCounterLabel.text = "[wave]" + str(pickup_counter)
	
	var pickup_effect_instance = pickup_effect.instantiate()
	%HUDLayer.add_child(pickup_effect_instance)
	pickup_effect_instance.get_node("Sprite2D").frame = pickup_sprite_frame
	pickup_effect_instance.get_node("Sprite2D").frame_coords.x = 1
	pickup_effect_instance.position = get_viewport().get_camera_3d().unproject_position(pickup_position)
	
	if head_tweener:
		head_tweener.kill()
	head_tweener = create_tween()
	head_tweener.tween_property(%headRect, "rotation_degrees", 40, 0.3).as_relative().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	head_tweener.tween_property(%headRect, "rotation_degrees", 0, 0.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	%headRect.rotation_degrees = clamp(%headRect.rotation_degrees, 0, 90)
	
	#Effect tweener
	var random_altitude = randi_range(16, 64)
	var altitude_tweener = create_tween()
	altitude_tweener.tween_property(pickup_effect_instance, "position:y", -random_altitude, 0.25).as_relative().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	altitude_tweener.tween_property(pickup_effect_instance, "position:y", pickup_marker_position.y, 0.25).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	
	var tweener = create_tween()
	tweener.tween_property(pickup_effect_instance, "position:x", pickup_marker_position.x, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tweener.parallel().tween_property(pickup_effect_instance, "scale", Vector2(0.5, 0.5), 0.5)
	await tweener.finished
	pickup_effect_instance.queue_free()

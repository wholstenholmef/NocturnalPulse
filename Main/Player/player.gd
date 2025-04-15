class_name Player
extends CharacterBody3D

signal on_death
signal death_VFX_finished

@export var show_debug : bool = false

@export var run_speed : float = 100
@export var cave_rotation_speed : int = 50
#QUITAR EL EXPORT!!! ES PARA PRUEBAS!!
#var in_cave := false
@export var play_intro := true

var track_position_z = 1.9
var track_id := 2

var gyro := false
var accelerometer_sensibility := 0.8

var movement_tweener
var rotation_tweener
var light_tweener
var accelerometer
var gyroscope

var pickup_counter : int = 0
var pickup_combo_counter : float = 0

#var state
#enum STATE_MACHINE {
	#RUNNING, 
	#MOVING, 
	#DEATH
#}
var mode_state 
enum MODE_STATE_MACHINE {
	INTRO,
	NORMAL,
	CAVE,
	TWO_DIMENSIONS,
	DEAD
}

func debug() -> void:
	if !show_debug:
		%DEBUGLayer.hide()
		return
	
	#accelerometer = Input.get_accelerometer()
	#gyroscope = Input.get_gyroscope()
	%gyroLabelX.text = "x:" + str(gyroscope.x)
	%gyroLabelY.text = "y:" + str(gyroscope.y)
	%gyroLabelZ.text = "z:" + str(gyroscope.z)
	
	%accelLabelX.text = "x:" + str(accelerometer.x)
	%accelLabelY.text = "y:" + str(accelerometer.y)
	%accelLabelZ.text = "z:" + str(accelerometer.z)

func _ready() -> void:
	if OS.get_name() == "Android":
		gyro = true
	
	if play_intro:
		intro()
		
	else:
		mode_state = MODE_STATE_MACHINE.NORMAL
	MusicNode.on_beat.connect(on_beat)

func intro() -> void:
	mode_state = MODE_STATE_MACHINE.INTRO
	get_viewport().get_camera_3d().change_camera_mode("INTRO")
	%HUDLayer.hide()
	%MainTrackLight.set_deferred("light_energy", 0)
	%softMainLight.set_deferred("light_energy", 0)
	%rythmSpotlight.set_deferred("light_energy", 0)
	$PajaroMesh/AnimationPlayer.stop()

func exit_intro() -> void:
	%HUDLayer.show()
	mode_state = MODE_STATE_MACHINE.NORMAL
	var tweener = create_tween()
	tweener.tween_property(self, "position", Vector3(0,3,0), 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	get_viewport().get_camera_3d().change_camera_mode("NORMAL")
	%MainTrackLight.set_deferred("light_energy", 8)
	%softMainLight.set_deferred("light_energy", 2)
	%rythmSpotlight.set_deferred("light_energy", 2)
	$PajaroMesh/AnimationPlayer.play("Armature_LAction_002")

func on_beat() -> void:
	if mode_state == MODE_STATE_MACHINE.DEAD:
		return
	if light_tweener:
		light_tweener.kill()
	light_tweener = create_tween()
	light_tweener.tween_property(%rythmSpotlight, "light_energy", 8, 0.1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	light_tweener.tween_property(%rythmSpotlight, "light_energy", 0, 0.2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	check_obstacle()

func check_obstacle() -> void:
	%obstacleRaycast.force_raycast_update()
	if %obstacleRaycast.get_collider() is ObstacleBase:
		%obstacleRaycast.get_collider().play_alert_VFX()

func _physics_process(delta: float) -> void:
	debug()
	if mode_state == MODE_STATE_MACHINE.DEAD:
		return
	if mode_state == MODE_STATE_MACHINE.INTRO:
		return
	#var accelerometer_force = remap(round(accelerometer.x), -8, 8, -track_position_z, track_position_z)
	#position.x = accelerometer_force
	
	#Clamp the tracks id to the actual tracks, left, center and right
	run(delta)
	get_input(delta)
	move_and_slide()

func change_mode(variant := "Normal") -> void:
	match variant:
		"NORMAL":
			mode_state = MODE_STATE_MACHINE.NORMAL
			get_viewport().get_camera_3d().change_camera_mode("NORMAL")
			MusicNode.exit_cave_transition()
			
			$PajaroMesh/AnimationPlayer.play("Armature_LAction_002")
			
			var tweener = create_tween()
			tweener.tween_property(self, "rotation_degrees:z", 0, 1.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		"CAVE":
			mode_state = MODE_STATE_MACHINE.CAVE
			get_viewport().get_camera_3d().change_camera_mode("CAVE")
			MusicNode.cave_transition()
			
			$PajaroMesh/AnimationPlayer.play("turn")
			#$PajaroMesh/AnimationPlayer.seek(0.28)
			$PajaroMesh/AnimationPlayer.stop()
			
			var tweener = create_tween()
			tweener.tween_property(self, "position:x", 0, 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		"TWO_DIMENSIONS":
			mode_state = MODE_STATE_MACHINE.TWO_DIMENSIONS
		
		"DEAD":
			mode_state = MODE_STATE_MACHINE.DEAD
			get_viewport().get_camera_3d().game_over()
			MusicNode.stop()
			
			%collisionAreaShape.set_deferred("disabled", true)
			%PajaroMesh.call_deferred("hide")
			%featherExplosionVFX.set_deferred("emitting", true)
			%sparkVFX.set_deferred("emitting", true)
			
			var tweener = create_tween()
			tweener.tween_property(%deathFlash, "light_energy", 2.5, 1.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
			tweener.chain().tween_property(%deathFlash, "light_energy", 0, 1.5).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
			await tweener.finished
			get_tree().get_first_node_in_group("transitionAnimation").play("fade_out")
			await get_tree().get_first_node_in_group("transitionAnimation").animation_finished
			get_tree().change_scene_to_file("res://Main/Main.tscn")

func run(delta) -> void:
	if mode_state == MODE_STATE_MACHINE.DEAD:
		return
	velocity.x = 0
	velocity.z = 0
	run_speed += 10 * delta
	run_speed = clamp(run_speed, 300, 700)
	velocity.z = -run_speed * delta

func get_input_gyro(delta) -> void:
	accelerometer = Input.get_accelerometer()
	match mode_state:
		MODE_STATE_MACHINE.NORMAL:
			if accelerometer.x <= -accelerometer_sensibility:
				$PajaroMesh/AnimationPlayer.play("turn")
				track_id = 1
				rotate_model(-15)
				move()
			elif accelerometer.x >= accelerometer_sensibility:
				$PajaroMesh/AnimationPlayer.play("turn")
				track_id = 3
				rotate_model(15)
				move()
			else:
				$PajaroMesh/AnimationPlayer.play("turn")
				track_id = 2
				move()
			
		MODE_STATE_MACHINE.CAVE:
			if accelerometer.x <= -accelerometer_sensibility:
				$PajaroMesh/AnimationPlayer.play("Armature_LAction_002")
				rotation_degrees.z -= cave_rotation_speed * delta
				rotate_model(-15)
			elif accelerometer.x >= accelerometer_sensibility:
				$PajaroMesh/AnimationPlayer.play("Armature_LAction_002")
				rotation_degrees.z += cave_rotation_speed * delta
				rotate_model(15)
			else:
				pass
		MODE_STATE_MACHINE.TWO_DIMENSIONS:
			pass
		MODE_STATE_MACHINE.DEAD:
			pass

func set_gyro(state = true) -> void:
	set_deferred("gyro", state)

func get_input(delta) -> void:
	if gyro:
		get_input_gyro(delta)
		return
	match mode_state:
		MODE_STATE_MACHINE.NORMAL:
			if Input.is_action_just_pressed("izquierda"):
				$PajaroMesh/AnimationPlayer.play("turn")
				track_id -= 1
				if track_id < 1:
					move_blocked(track_id)
				track_id = clamp(track_id, 1, 3)
				move()
				rotate_model(-15)
			if Input.is_action_just_pressed("derecha"):
				$PajaroMesh/AnimationPlayer.play("turn_right")
				track_id += 1
				if track_id > 3:
					move_blocked(track_id)
				track_id = clamp(track_id, 1, 3)
				rotate_model(15)
				move()
		MODE_STATE_MACHINE.CAVE:
			if Input.is_action_pressed("izquierda"):
				rotation_degrees.z -= cave_rotation_speed * delta
				rotate_model(-15)
			if Input.is_action_pressed("derecha"):
				rotation_degrees.z += cave_rotation_speed * delta
				rotate_model(15)
		MODE_STATE_MACHINE.TWO_DIMENSIONS:
			pass
		MODE_STATE_MACHINE.DEAD:
			pass

func move() -> void:
	var final_position
	match track_id:
		1:
			final_position = -track_position_z
			MusicNode.tween_tracks(0, 0, -16, -16, 1)
		2:
			final_position = 0
			MusicNode.tween_tracks(-3, -3, -3, -3, 1)
		3:
			final_position = track_position_z
			MusicNode.tween_tracks(-16, -16, 0, 0, 1)
	if movement_tweener:
		movement_tweener.kill()
	movement_tweener = create_tween()
	movement_tweener.tween_property(self, "position:x", final_position, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)

func move_blocked(blocked_track_id) -> void:
	var final_position
	if blocked_track_id < 1:
		final_position = -track_position_z -1
	else:
		final_position = track_position_z +1
	if movement_tweener:
		movement_tweener.kill()
	movement_tweener = create_tween()
	movement_tweener.tween_property(self, "position:x", final_position, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	movement_tweener.tween_property(self, "position:x", final_position, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)

func rotate_model(z_degrees := 0) -> void:
	if rotation_tweener:
		rotation_tweener.kill()
	rotation_tweener = create_tween()
	rotation_tweener.tween_property($PajaroMesh, "rotation_degrees:z", z_degrees, 0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	rotation_tweener.tween_property($PajaroMesh, "rotation_degrees:z", 0, 0.25).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)

func _on_pickup_area_area_entered(area: Area3D) -> void:
	if area.is_in_group("PickupArea"):
		pickup_counter += 1
		pickup_combo_counter += 1
		%HUDLayer.on_pickup(area.global_transform.origin, pickup_counter, area.get_node("Sprite3D").frame)
		%crunchSFX.play()
		var variable_pitch_scale : float = 1.0 + (pickup_combo_counter/5)
		%crunchSFX.pitch_scale = variable_pitch_scale
		%crunchSFXComboTimer.start()
		area.queue_free()

func _on_crunch_sfx_combo_timer_timeout() -> void:
	pickup_combo_counter = 0

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match mode_state:
		MODE_STATE_MACHINE.NORMAL:
			$PajaroMesh/AnimationPlayer.queue("Armature_LAction_002")
		MODE_STATE_MACHINE.CAVE:
			pass

func _on_collision_area_body_entered(body: Node3D) -> void:
	if body is ObstacleBase:
		change_mode("DEAD")

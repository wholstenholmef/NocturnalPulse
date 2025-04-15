extends Camera3D

@export_node_path("Player") var target
var target_node : Player
var camera_offset : Vector3

var camera_tweener 

var state 
enum STATE_MACHINE {
	INTRO,
	RUNNER,
	CAVE,
	GAME_OVER
}

func _ready() -> void:
	camera_offset = self.position
	target_node = get_node_or_null(target)

func _physics_process(delta: float) -> void:
	if target == null:
		return
	if !is_instance_valid(target_node):
		return
	#position.y = target_node.global_position.y + camera_offset.y
	#position.x = target_node.global_position.x
	if state == STATE_MACHINE.GAME_OVER:
		return
	if state == STATE_MACHINE.INTRO:
		return
	
	position.z = target_node.global_position.z + camera_offset.z
	position.y = camera_offset.y
	#position.z = lerp(position.z, target_node.global_position.z, 0.1)
	position.x = lerp(position.x, target_node.global_position.x, 0.1)
	#rotation_degrees.z = lerp(rotation_degrees.z, target_node.rotation_degrees.z, 0.1)
	rotation.z = target_node.global_rotation.z 

func change_camera_mode(variant = "NORMAL") -> void:
	var final_position := Vector3.ZERO
	match variant:
		"INTRO":
			state = STATE_MACHINE.INTRO
		"NORMAL":
			state = STATE_MACHINE.RUNNER
			final_position = %normalCameraMarker.position
			var tweener = create_tween()
			tweener.tween_property(self, "rotation:y", 0, 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		"CAVE":
			state = STATE_MACHINE.CAVE
			final_position = %caveCameraMarker.position
		#"DEATH":
			#game_over()
	
	if camera_tweener:
		camera_tweener.kill()
	camera_tweener = create_tween()
	camera_tweener.tween_property(self, "camera_offset", final_position, 1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)

func game_over() -> void:
	state = STATE_MACHINE.GAME_OVER
	var tweener = create_tween()
	tweener.tween_property(self, "position:z", 1.5, 1).as_relative().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)

extends Node3D

@export var cave_frequency : int = 5
@export var max_instanced_segments : int = 3
var runner_segment_counter : int = 0

var cave_segment_total_length : int = 5
var cave_segment_counter : int = 0

#var segment_node = preload("res://Main/SegmentBase/segmentBase.tscn")
var cave_entrance_segment = preload("res://Main/SegmentBase/CaveTriggers/cave_trigger_open.tscn")
var cave_exit_segment = preload("res://Main/SegmentBase/CaveTriggers/cave_trigger_exit.tscn")

var runner_segments_path = "res://Main/Segments/"
var cave_segments_path = "res://Main/CaveSegments/"
var segment_suffix = ".tscn"
var runner_segments_array : Array = []
var cave_segments_array : Array = []

var mode_state 
enum MODE_STATE_MACHINE {
	RUNNER,
	CAVE
}

func _ready() -> void:
	randomize()
	%TransitionAnimationPlayer.play("fade_in")
	call_deferred("load_segments", runner_segments_path)
	call_deferred("load_segments", cave_segments_path)
	#MusicNode.play_ost(0)
	mode_state = MODE_STATE_MACHINE.RUNNER

func load_segments(path = "res://Main/Segments/") -> void:
	for i in range(1, 99):
		var selected_segment_path = path + str(i) + segment_suffix
		#print(ResourceLoader.exists(selected_segment_path))
		if ResourceLoader.exists(selected_segment_path):
			#print("yay")
			var segment_instance = load(selected_segment_path)
			match path:
				runner_segments_path:
					runner_segments_array.append(segment_instance)
				cave_segments_path:
					cave_segments_array.append(segment_instance)
		else:
			break
	
	#var dir = DirAccess.open(path)
	#if dir:
		#dir.list_dir_begin()
		#var file_name = dir.get_next()
		#while file_name != "":
			#if file_name.get_extension() == "tscn":
				#var full_path = path.path_join(file_name)
				#match path:
					#runner_segments_path:
						#runner_segments_array.append(load(full_path))
					#cave_segments_path:
						#cave_segments_array.append(load(full_path))
			#file_name = dir.get_next()
	#else:
		#print("error en ruta")
	#print(runner_segments_array)

func _on_segment_base_player_passed(marker_position) -> void:
	match mode_state:
		MODE_STATE_MACHINE.RUNNER:
			runner_segment_counter += 1
			if runner_segment_counter >= cave_frequency:
				mode_state = MODE_STATE_MACHINE.CAVE
				runner_segment_counter = 0
				call_deferred("generate_segment", cave_entrance_segment, marker_position)
				#generate_cave_entrance(marker_position)
				return
			call_deferred("generate_segment", runner_segments_array.pick_random(), marker_position)
			#generate_runner_segment(marker_position)
		MODE_STATE_MACHINE.CAVE:
			cave_segment_counter += 1
			if cave_segment_counter >= cave_segment_total_length:
				mode_state = MODE_STATE_MACHINE.RUNNER
				cave_segment_counter = 0
				call_deferred("generate_segment", cave_exit_segment, marker_position)
				#generate_cave_exit(marker_position)
				return
			call_deferred("generate_segment", cave_segments_array.pick_random(), marker_position)
			#generate_cave_segment(marker_position)
	#var segment_instance : segmentBase = segment_node.instantiate()

func generate_segment(segment_path , segment_position := Vector3.ZERO) -> void:
	var segment_instance = segment_path.instantiate()
	%SegmentsNode.call_deferred("add_child", segment_instance)
	segment_instance.position = segment_position
	segment_instance.player_passed.connect(_on_segment_base_player_passed)
	
	if %SegmentsNode.get_child_count() > max_instanced_segments:
		%SegmentsNode.get_children()[0].queue_free()

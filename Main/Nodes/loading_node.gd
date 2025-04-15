extends Node3D

var main_node = preload("res://Main/Main.tscn")
var runner_segments_path = "res://Main/Segments/"
var cave_segments_path = "res://Main/CaveSegments/"
var segment_suffix = ".tscn"
var runner_segments_array : Array = []
var cave_segments_array : Array = []

func _ready() -> void:
	load_segments()
	load_segments(cave_segments_path)
	call_deferred("gen_segments")
	var tweener = create_tween()
	tweener.tween_property($Camera3D, "position:z", -45, 5)

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

func gen_segments() -> void:
	for segment in runner_segments_array:
		var instance = segment.instantiate()
		add_child(instance)
	for segment in cave_segments_array:
		var instance = segment.instantiate()
		add_child(instance)
	%levelLoadLabel.text = "[pulse]" + (str(runner_segments_array.size() + cave_segments_array.size())) + " niveles cargados"

func _on_timer_timeout() -> void:
	get_tree().call_deferred("change_scene_to_packed", main_node)

class_name ObstacleBase
extends StaticBody3D

@export_enum("Forest", "Cave", "Cave_wall") var enviroment : String = "Forest"

var forest_meshes = [
	"res://Meshes/stone.tres",
	"res://Meshes/tree.tres",
	"res://Meshes/bush.tres",
	"res://Meshes/stump.tres"
]

var cave_meshes = [
	"res://Meshes/stone1.tres"
]

var stone_textures_path = "res://Assets/Stones/stone"
var texture_suffix = ".png"

func _ready() -> void:
	$Icon.hide()
	var selected_mesh_path
	var random_mesh
	match enviroment:
		"Forest":
			selected_mesh_path = forest_meshes.pick_random()
			random_mesh = load(selected_mesh_path)
		"Cave":
			selected_mesh_path = cave_meshes.pick_random()
			random_mesh = load(selected_mesh_path)
		_:
			return
	#if random_mesh == "res://Meshes/stone1.tres"
	$MeshInstance3D.set_deferred("mesh", random_mesh)
	if selected_mesh_path == "res://Meshes/stone1.tres":
		$MeshInstance3D.set_deferred("mesh:material:albedo_texture", load(stone_textures_path + str(randi_range(1, 4)) + texture_suffix))

func play_alert_VFX() -> void:
	%AlertaSFX.call_deferred("play")

extends ObstacleBase

var wall_mesh_path := "res://Meshes/wall_obstacles/wall_obstacle"
var wall_mesh_collision_path := "res://Meshes/wall_obstacles/CollisionShapes/wall_obstacle_shape"
var suffix := ".tres"

@export_enum("1", "2", "3") var wall_obstacle_id : String = "1"

func _ready() -> void:
	super()
	$MeshInstance3D.mesh = load(wall_mesh_path + wall_obstacle_id + suffix)
	$CollisionShape3D.shape = load(wall_mesh_collision_path + wall_obstacle_id + suffix)

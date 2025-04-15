class_name segmentBase
extends Node3D

signal player_passed
@export_enum("EASY", "NORMAL", "HARD") var difficulty : String = "EASY"

func _ready() -> void:
	if get_node_or_null("%Trees"):
		%Trees.show()

func _on_player_area_body_entered(body: Node3D) -> void:
	if body is Player:
		player_passed.emit(%endOfSegmentMarker.global_position)

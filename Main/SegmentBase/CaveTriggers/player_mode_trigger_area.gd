extends Area3D

@export_enum("NORMAL", "CAVE", "TWO_DIMENSIONS") var TRIGGER_MODE : String = "NORMAL"

func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		body.change_mode(TRIGGER_MODE)

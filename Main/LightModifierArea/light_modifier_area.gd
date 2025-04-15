extends Area3D

@export var light_modifier : float = 0
@export var transition_duration : float = 1.0

func _on_body_entered(body: Node3D) -> void:
	if body is not Player:
		return
	get_tree().get_first_node_in_group("WorldEnviroment").set_light_energy(light_modifier)

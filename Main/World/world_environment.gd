extends WorldEnvironment

var tweener

func set_light_energy(energy : float = 0, duration : float = 1) -> void:
	if tweener:
		tweener.kill()
	#var sky_energy_multiplier = self.environment.sky.sky_material.sky_energy_multiplier
	tweener = create_tween()
	tweener.tween_property(self, "environment:sky:sky_material:sky_energy_multiplier", energy, duration)

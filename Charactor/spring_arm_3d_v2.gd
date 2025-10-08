extends SpringArm3D

@export var mouse_sensibility = 0.005

func _unhandled_input(event: InputEvent) -> void:
	if (event is InputEventMouseMotion):
		rotation.y -= event.relative.x * mouse_sensibility
		rotation.y = wrapf(rotation.y, 0.0, TAU)
		
		rotation.x -= event.relative.y * mouse_sensibility
		rotation.x = clamp(rotation.x, -PI/2, PI/4)
		
#func _process(delta: float) -> void:

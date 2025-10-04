extends SpringArm3D

@export var mouse_sensibility = 0.005

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x * mouse_sensibility
		rotation.x += event.relative.y * mouse_sensibility
		
#func _process(delta: float) -> void:

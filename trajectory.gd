extends RigidBody3D

var explode_effect_scene = preload("res://explosion.tscn")
var explode_effect
var explode_sfx_sound = preload("res://sound/large-underwater-explosion.mp3")
var explode_sfx

var battery_position

signal hit(sfx, effect, hit_position, fire_position)

func _init() -> void:
	mass = 4 # kg
	explode_effect = explode_effect_scene.instantiate()
	explode_sfx = AudioStreamPlayer3D.new()
	explode_sfx.stream = explode_sfx_sound
	
func _physics_process(delta: float) -> void:
	if linear_velocity.length_squared() > 1:
		var new_y_axis = linear_velocity.normalized()	
		var current_y_axis = global_transform.basis.y
		var new_x_axis = current_y_axis.cross(new_y_axis).normalized()

		var new_z_axis = new_y_axis.cross(new_x_axis).normalized()
		
		# 5. Apply the new basis to the global transform
		global_transform.basis.x = new_x_axis
		global_transform.basis.y = new_y_axis
		global_transform.basis.z = new_z_axis * -1 # Assuming forward is -Z (standard Godot convention)
	
	else:
		await get_tree().create_timer(3).timeout
		queue_free()
		
		
func _integrate_forces(state):
	if state.get_contact_count() > 0:
		hit.emit(explode_sfx, explode_effect, global_position, battery_position)
		queue_free()

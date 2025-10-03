extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_gun_fire(bullet_obj, muzzle, bullet_speed) -> void:
	bullet_obj.hit.connect(_on_explode)
	add_child(bullet_obj)
	bullet_obj.global_transform = muzzle.global_transform
	var forward_vector: Vector3 = bullet_obj.global_transform.basis.y
	bullet_obj.linear_velocity = forward_vector * bullet_speed
	
func _on_explode(explosion_sfx, explosion_effect, hit_position):
	add_child(explosion_sfx)
	explosion_sfx.play()
	add_child(explosion_effect)
	explosion_effect.global_position = hit_position
	
	

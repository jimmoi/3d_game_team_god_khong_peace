extends Node3D

@export var sound_speed = 333 # m/s

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(Manager.players)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_gun_fire(bullet_obj, muzzle, bullet_speed) -> void:
	add_child(bullet_obj)
	bullet_obj.global_transform = muzzle.global_transform
	var forward_vector: Vector3 = bullet_obj.global_transform.basis.y
	bullet_obj.linear_velocity = forward_vector * bullet_speed
	bullet_obj.hit.connect(_on_explode)
	
func _on_explode(explosion_sfx, explosion_effect, hit_position, battery_position):
	add_child(explosion_sfx)
	add_child(explosion_effect)
	explosion_effect.global_position = hit_position
	var delay_sound_sec = abs((hit_position-battery_position).length())/sound_speed
	await get_tree().create_timer(delay_sound_sec).timeout
	explosion_sfx.play()
		
	

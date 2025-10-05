extends Node3D

@export var sound_speed = 333 # m/s
var boat_scene = {"Battleship":preload("res://Charactor/battleship.tscn"),
					"Cruiser":preload("res://Charactor/cruiser.tscn"),
					"Destroyer":preload("res://Charactor/destroyer.tscn")}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(Manager.players.size()):
		var player = Manager.players.values()[i]
		var temp_ship_node = boat_scene[player["role"]].instantiate()
		var gun = temp_ship_node.get_node("model").get_node("gun")
		gun.fire.connect(_on_gun_fire)
		add_child(temp_ship_node)
		var angle = randf() * TAU # มุมรอบวงกลม (0 ถึง 2π)
		var distance = randf() * 3000.0 # ระยะทางจากศูนย์กลาง (0 ถึง 3000)

		# คำนวณตำแหน่ง (ในระนาบ XZ ถ้าเป็น 3D)
		var pos = Vector3(
			cos(angle) * distance,
			0.0,  # ความสูง (Y) = 0
			sin(angle) * distance
		)

		temp_ship_node.global_transform.origin = pos
		player["ship_node"] = temp_ship_node
	
	game_turn()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func game_turn():
	var curr_turn = randi() % Manager.selected_game_mode
	while true:
		var focus_player = Manager.players.values()[curr_turn]
		var ship = focus_player["ship_node"]
		var ship_cam = ship.get_node("Camera3D")
		var gun = ship.get_node("model").get_node("gun")
		ship_cam.make_current()
		ship.on_use = true
		await get_tree().create_timer(5).timeout
		ship.on_use = false
		gun.on_use = true
		await get_tree().create_timer(120).timeout
		gun.on_use = false
		gun.mortar_status = true
		curr_turn += 1
		curr_turn %= Manager.selected_game_mode
	
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
		
	

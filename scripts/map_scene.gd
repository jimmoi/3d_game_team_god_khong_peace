extends Node3D

@export var sound_speed = 333 # m/s
var boat_scene = {"Battleship":preload("res://Charactor/battleship.tscn"),
					"Cruiser":preload("res://Charactor/cruiser.tscn"),
					"Destroyer":preload("res://Charactor/destroyer.tscn")}
var button_panel:HBoxContainer
var button:Dictionary

signal any_signal_received(chosen_action: String)
signal end_move
signal end_fire(hit_position)

var focus_player:Dictionary

var prev_ship_loc:Vector3
var new_ship_loc:Vector3
var check_distance = false
var temp_distance:int
var position_valid = false

var fire_state = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$MeshInstance3D.mesh.set_top_radius(Manager.map_radius)
	$MeshInstance3D.mesh.set_bottom_radius(Manager.map_radius)
	$floor/CollisionShape3D.shape.set_radius(Manager.bound_radius)
	#$CSGCombiner3D/CSGCylinder3D.radius = Manager.map_radius
	#$CSGCombiner3D/CSGCylinder3D/CSGCylinder3D2.radius = Manager.map_radius*1.5
	
	$Control/Label.visible = false
	$Control/ShowDistance.visible = false
	button_panel = $Control/HBoxContainer
	button_panel.visible = false
	button = {
		"move":	$Control/HBoxContainer/Button_move,
		"skill": $Control/HBoxContainer/Button_skill,
		"confirm": $Control/Button_confirm
	}
	button["confirm"].visible = false
	
	for i in range(Manager.players.size()):
		var player = Manager.players.values()[i]
		var temp_ship_node = boat_scene[player["role"]].instantiate()
		var gun = temp_ship_node.get_node("model").get_node("gun")
		gun.fire.connect(_on_gun_fire)
		add_child(temp_ship_node)
		var angle = randf() * TAU # มุมรอบวงกลม (0 ถึง 2π)
		var distance = randf() * Manager.map_radius * 0.9 # ระยะทางจากศูนย์กลาง (0 ถึง 3000)

		# คำนวณตำแหน่ง (ในระนาบ XZ ถ้าเป็น 3D)
		var pos = Vector3(
			cos(angle) * distance,
			0.0,  # ความสูง (Y) = 0
			sin(angle) * distance
		)

		temp_ship_node.global_position = pos
		temp_ship_node.visible = false
		player["ship_node"] = temp_ship_node
	game_turn()
	
func _process(delta: float) -> void:
	pass
	
	if check_distance:
		var player_ship = focus_player["ship_node"]
		var diff_distance = (player_ship.global_position - prev_ship_loc).length()
		if diff_distance <= player_ship.movable_distance:
			$Control/ShowDistance.text = "Distance moved: %d" % diff_distance
			position_valid = true
			button["confirm"].add_theme_color_override("font_color", Color("00d556ff"))
		else:
			$Control/ShowDistance.text = "Invalid, Distance moved: %d" % diff_distance
			position_valid = false
			button["confirm"].add_theme_color_override("font_color", Color("ff0000"))


func game_turn():
	var curr_turn = randi() % Manager.selected_game_mode
	$Control/Label.visible = true
	var sub_round = 1
	var prim_round = Manager.event_round
	while true:
		var focus_player = Manager.players.values()[curr_turn]
		var ship = focus_player["ship_node"]
		var ship_cam = ship.get_node("SpringArm3D").get_node("camera")
		var gun = ship.get_node("model").get_node("gun")
		ship.visible = true
		ship_cam.make_current()
		if sub_round % (Manager.selected_game_mode+1) == 0:
			sub_round = 1
			prim_round -= 1
			if prim_round == -1:
				prim_round = Manager.event_round
			
		$Control/Label.text = "Time to Event: %d" % prim_round
		# let's player select mode
		if prim_round == 0:
			$Control/Label.text = "Time to Event: %d" % prim_round
			button_panel.visible = true
			var chosen_action = await any_signal_received 
			button_panel.visible = false
			if chosen_action=="move":
				prev_ship_loc = ship.global_position
				button["confirm"].visible = true
				ship.on_use = true
				check_distance = true
				$Control/ShowDistance.visible = true
				await end_move
				button["confirm"].visible = false
				check_distance = false
				$Control/ShowDistance.visible = false
			elif chosen_action=="skill":
				# do skill logic
				# ship.skill
				pass
		
		# fire sequence
		ship.on_use = false
		gun.on_use = true
		var hit_positiob = await end_fire
		var nearest_distance = calculate_the_nearest_ship(hit_positiob, curr_turn)
		print(nearest_distance)
		await get_tree().create_timer(3).timeout
		
		ship.visible = false
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
	end_fire.emit(hit_position)
	
func calculate_the_nearest_ship(hit_position, curr_turn):
	var distances = []
	for i in range(Manager.players.size()):
		if i == curr_turn:
			pass
		var player = Manager.players.values()[i]
		var player_ship = player["ship_node"]
		var temp_distance = (player_ship.global_position-hit_position).length()
		distances.append(temp_distance)
		
	var nearest_distance = distances.min()
	return nearest_distance

func _on_button_move_pressed() -> void:
	any_signal_received.emit("move")

func _on_button_skill_pressed() -> void:
	any_signal_received.emit("skill")

func _on_button_confirm_pressed() -> void:
	var player_ship = focus_player["ship_node"]
	if position_valid:
		end_move.emit()

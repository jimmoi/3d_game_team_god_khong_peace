extends Node3D

@export var sound_speed = 333 # m/s
var boat_scene = {"Battleship":preload("res://Charactor/battleship.tscn"),
					"Cruiser":preload("res://Charactor/cruiser.tscn"),
					"Destroyer":preload("res://Charactor/destroyer.tscn")}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(Manager.players)
	print(Manager.players.values())
	for i in Manager.players:
		print(i)
		var player = Manager.players.values()[i-1]
		var temp_node = boat_scene[player["role"]].instantiate()
		add_child(temp_node)
		var angle = randf() * TAU # มุมรอบวงกลม (0 ถึง 2π)
		var distance = randf() * 3000.0 # ระยะทางจากศูนย์กลาง (0 ถึง 3000)

		# คำนวณตำแหน่ง (ในระนาบ XZ ถ้าเป็น 3D)
		var pos = Vector3(
			cos(angle) * distance,
			0.0,  # ความสูง (Y) = 0
			sin(angle) * distance
		)

		temp_node.global_transform.origin = pos
		player["boat_node"] = temp_node
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
		
	

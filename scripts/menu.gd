
extends Control

const NEXT_SCENE = preload("res://scene/map_scene.tscn")

var main_menu
var game_mode_menu
var role_select_menu

var player_i = 1
var player_role_temp

func _ready() -> void:
	game_mode_menu = $VBoxContainer_game_mode
	role_select_menu = $VBoxContainer2_select_role
	
	$Button_play.visible = true
	game_mode_menu.visible = false
	role_select_menu.visible = false
	var i = 1
	for role in Manager.role:
		role_select_menu.get_node("Button_role_%s" % i).text = role
		i += 1
	
func _on_play_button_pressed() -> void:
	ui_select_player_amount()
	
func ui_select_player_amount():
	$Button_play.visible = false
	game_mode_menu.visible = true

func _on_button_2_player_pressed() -> void:
	Manager.selected_game_mode = Manager.game_mode["Two"]
	create_player()


func _on_button_3_player_pressed() -> void:
	Manager.selected_game_mode = Manager.game_mode["Three"]
	create_player()
	
func create_player():
	game_mode_menu.visible=false
	role_select_menu.visible=true
	Manager.create_init_player()
	role_select_menu.get_node("Label").text = "PLAYER : %d" %  (player_i)
	


func _on_button_role_1_pressed() -> void:
	player_role_temp = $VBoxContainer2_select_role/Button_role_1.text
	Manager.players[player_i]["role"] = player_role_temp
	player_i += 1
	role_select_menu.get_node("Label").text = "PLAYER : %d" %  (player_i)
	check_next_scene()

func _on_button_role_2_pressed() -> void:
	player_role_temp = $VBoxContainer2_select_role/Button_role_2.text
	Manager.players[player_i]["role"] = player_role_temp
	player_i += 1
	role_select_menu.get_node("Label").text = "PLAYER : %d" %  (player_i)
	check_next_scene()

func _on_button_role_3_pressed() -> void:
	player_role_temp = $VBoxContainer2_select_role/Button_role_3.text
	Manager.players[player_i]["role"] = player_role_temp
	player_i += 1
	role_select_menu.get_node("Label").text = "PLAYER : %d" %  (player_i)
	check_next_scene()
	
func check_next_scene():
	if player_i == Manager.selected_game_mode+1:
		get_tree().change_scene_to_packed(NEXT_SCENE)

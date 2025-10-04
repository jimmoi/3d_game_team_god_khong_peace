extends Node


var game_mode = {"Two":2, "Three":3}
enum role {Battleship, Cruiser, Destroyer}
var selected_game_mode
var players

func create_init_player():
	players = {}
	for i in range(selected_game_mode):
		players[i+1] = {}

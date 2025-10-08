extends Node


var game_mode = {"Two":2, "Three":3}
enum role {Battleship, Cruiser, Destroyer}
var selected_game_mode
var players

var event_round = 0
var map_radius = 30
var bound_radius = 3000

var damage_per_round = 10

func create_init_player():
	players = {}
	for i in range(selected_game_mode):
		players[i+1] = {}

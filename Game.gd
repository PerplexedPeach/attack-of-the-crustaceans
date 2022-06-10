extends Node

export(NodePath) var exploration_screen

const PLAYER_WIN = "res://dialogue/dialogue_data/player_won.json"
const PLAYER_LOSE = "res://dialogue/dialogue_data/player_lose.json"

func _ready():
	exploration_screen = get_node(exploration_screen)

class_name GameManager
extends Node2D

# Game Manager ist eine art schnitt stelle auf die jedes elemnt zugruf hatt kinda,
# und in ihm befindet sich auch der Gameplay-Loop 

@onready var board: Board = $Board
@onready var game_hud: HUD = $UI/HUD
@onready var player1: Player = $Player1
@onready var player2: Player = $Player2
@onready var mcts_graph_window: Window = $MCTSGraphEditWindow
var is_game_done: bool = true
var is_game_set_up: bool = false
var is_game_reset: bool = true
var winner: String
var turn_counter: int = 1 # zählt die runden ungerade ist spiler 1 gerade spieler 2
var win_combinations: Array[PackedInt32Array] = [
	PackedInt32Array([0, 1, 2]), # 1st row
	PackedInt32Array([3, 4, 5]), # 2nd row
	PackedInt32Array([6, 7, 8]), # 3rd row
	PackedInt32Array([0, 3, 6]), # 1st column
	PackedInt32Array([1, 4, 7]), # 2nd column
	PackedInt32Array([2, 5, 8]), # 3rd column
	PackedInt32Array([0, 4, 8]), # 1st diagonal
	PackedInt32Array([2, 4, 6]),# 2nd diagonal
]

# 
func _ready() -> void:
	game_hud.connect("button_pressed", _on_button_pressed)
	game_hud.connect("reset_pressed", _on_reset_pressed)
	game_hud.connect("graph_button_pressed", _on_graph_button_pressed)
	game_hud.hide_ingame_text()

# wenn jeweiliger button gedrückt dann arbeite damit  und führe aus was drin steht 
func _on_button_pressed():
	if not is_game_set_up and is_game_reset:
		setup_game()
		is_game_done = false

# hide graph window on x press
func _on_graph_button_pressed() -> void:
	if not mcts_graph_window.visible:
		mcts_graph_window.visible = true

#logik für reset button
func _on_reset_pressed():
	if is_game_done and not is_game_reset:
		get_tree().reload_current_scene()

## In dieser Methode werden  durch die Auwahl in den Option Button gewähltes elemnet gewählt  so weiß der spieler welchen Algo er
## verweden soll
func setup_game():
	# erste zeile gibt den index der ausgewählten elemnte der OptionButtons im HUD skript 
	var selection = game_hud.get_selected_players()
	player1.add_algorithm_to_player(selection[0]) 
	player2.add_algorithm_to_player(selection[1])
	
	if player1.algorithm is Min_Max:
		game_hud.min_max_info_label_1.show()
	elif player2.algorithm is Min_Max:
		game_hud.min_max_info_label_2.show()
	
	is_game_set_up = true

## schaut ob eine runde gewonnen ist indem es alle möglichen win kombinationen durch geht 
func game_is_won():
	var board = board.get_list_of_fields()
	var win_combinations = [[0,1,2],[3,4,5],[6,7,8],[2,4,6],[0,4,8],[0,3,6],[1,4,7],[2,5,8]]
	for combinations in win_combinations:
		var values: Array[Field] = []
		for index in combinations:
			values.append(board[index])
		if values[0].get_content() != "" and values[0].get_content() == values[1].get_content() and values[1].get_content() == values[2].get_content():
			winner = values[0].get_content()
			return true 
	return false 

## schaue ob unentscheiden 	
func check_draw():
	# Iteriere durch alle Felder
	for board in board.get_list_of_fields():
		# Prüfe, ob ein Feld leer ist
		if board.get_content() == "":
			# Wenn ein Feld leer ist, gibt es noch kein Unentschieden
			return false
	# Wenn keine Felder leer sind, ist es ein Unentschieden
	return true

## gameloop
func _physics_process(delta: float) -> void:
	if is_game_set_up:
		if not game_is_won() and not check_draw():
			if turn_counter % 2 != 0:
				
				await player1.turn()
			else:
				await player2.turn()
		else:
			if game_is_won():
				game_hud.set_ingame_text(winner + " is the Winner")
			elif not check_draw():
				game_hud.set_ingame_text("Nobody is the Winner")
			else:
				game_hud.set_ingame_text("Draw!")
			is_game_reset = false
			is_game_done = true
			is_game_set_up = false

class_name GameManager
extends Node2D

# Game Manager ist eine art schnitt stelle auf die jedes elemnt zugruf hatt kinda,
# und in ihm befindet sich auch der Gameplay-Loop 

@onready var board: Board = $Board
@onready var game_hud: HUD = $UI/HUD
@onready var player1: Player = $Player1
@onready var player2: Player = $Player2
@onready var mcts_graph_window_one: Window = $MCTSGraphEditWindow1
@onready var mcts_graph_window_two: Window = $MCTSGraphEditWindow2
@onready var mcts_next_button: Button = $UI/HUD/MCTSNextButton
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

func _ready() -> void:
	game_hud.connect("play_button_pressed", _on_play_button_pressed)
	game_hud.connect("reset_button_pressed", _on_reset_pressed)
	self.mcts_graph_window_one.visible = false
	self.mcts_graph_window_two.visible = false
	self.mcts_next_button.visible = false
	self.mcts_next_button.disabled = true
	game_hud.hide_ingame_text()

# wenn jeweiliger button gedrückt dann arbeite damit  und führe aus was drin steht 
func _on_play_button_pressed():
	if not is_game_set_up and is_game_reset:
		setup_game()
		is_game_done = false

# logik für reset button
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
	
	# enable graph window button for each player if MCTS algorithm assigned
	if player1.algorithm is MCTSAlgorithm:
		# check if iteration field has a value
		if len(self.game_hud.iteration_line_edit_one.text) == 0 or int(self.game_hud.iteration_line_edit_one.text) < 1000:
			return
		self.player1.algorithm.iterations = int(self.game_hud.iteration_line_edit_one.text)
		self.game_hud.graph_window_button_one.disabled = false
	if player2.algorithm is MCTSAlgorithm:
		# check if iteration field has a value
		if len(self.game_hud.iteration_line_edit_two.text) == 0 or int(self.game_hud.iteration_line_edit_two.text) < 1000:
			return
		self.player2.algorithm.iterations = int(self.game_hud.iteration_line_edit_two.text)
		self.game_hud.graph_window_button_two.disabled = false
	# MCTS vs mcts special case
	if player1.algorithm is MCTSAlgorithm and player2.algorithm is MCTSAlgorithm:
		self.mcts_next_button.visible = true
		self.mcts_next_button.disabled = false

	is_game_set_up = true

## schaut ob eine runde gewonnen ist indem es alle möglichen win kombinationen durch geht 
func game_is_won():
	var board = board.get_list_of_fields()
	for combinations in self.win_combinations:
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
				game_hud.show_ingame_text()
				game_hud.set_ingame_text(winner + " is the Winner")
			elif not check_draw():
				game_hud.show_ingame_text()
				game_hud.set_ingame_text("Nobody is the Winner")
			else:
				game_hud.show_ingame_text()
				game_hud.set_ingame_text("Draw!")
			is_game_reset = false
			is_game_done = true
			is_game_set_up = false

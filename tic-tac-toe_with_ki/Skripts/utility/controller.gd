class_name Controller
extends Node2D

var board: Board
var game_manager: GameManager
var player_name: String
var win_combinations: Array[PackedInt32Array]

# Konstruktor für jeden Algorithmus der noch kommen marg 
func _init(game_manager: GameManager, player_name: String) -> void:
	if game_manager and player_name:
		self.board = game_manager.board
		self.game_manager = game_manager
		self.player_name = player_name
		self.win_combinations = game_manager.win_combinations

# das ist die methdode in der am ende dan die aktion des ALgorithmus es ausgeführt wird 
# sie sollte immer ein " feld " als zuückgarbe an dei turn methdoe vom spiler geben 
func action() -> Variant:
	return

# schaut einfach ob es ein gewinner gibt oder unenscheiden ist ,  hatte ich für MinMAx gebarucht vl kann man es auch für MCTS benutzen 
func check_winner() -> Variant:
	var current_board = self.board.get_list_of_fields()
	for combinations in self.win_combinations:
		var values: Array[Field] = []
		for index in combinations:
			values.append(current_board[index])
		if values[0].get_content() != "" and values[0].get_content() == values[1].get_content() and values[1].get_content() == values[2].get_content():
			return values[0].get_content() 
	for field in self.board.get_list_of_fields():
		# Prüfe, ob ein Feld leer ist
		if field.get_content() == "":
			# Wenn ein Feld leer ist, gibt es noch kein Unentschieden
			return null
	return "draw"

class_name Player
extends Node2D

@export var game_manager: GameManager
@onready var symbol_x: PackedScene = preload("res://Scenes/game_elements/x_character.tscn")
@onready var symbol_o: PackedScene = preload("res://Scenes/game_elements/o_character.tscn")
var algorithm: Controller
var selected_field: Field

# elemnte sind hier X oder O
func spawn_element(field: Field, symbol: PackedScene):
	var instance = symbol.instantiate()
	if field.get_children().size() < 2:
		field.add_child(instance)

func add_algorithm_to_player(algorithm_id: int):
	if algorithm_id == 0:
		self.algorithm = HumanPlayer.new(self.game_manager, self.get_name())
		self.add_child(self.algorithm)
	if algorithm_id == 1:
		self.algorithm = MinMax.new(self.game_manager, self.get_name())
		self.add_child(self.algorithm)
	if algorithm_id == 2:
		self.algorithm = MCTSAlgorithm.new(self.game_manager, self.get_name())
		self.add_child(self.algorithm)
	#match algorithm_id:
		#0: self.algorithm = HumanPlayer.new(game_manager.board, game_manager, self.get_name())
		#1: self.algorithm = MinMax.new(game_manager.board, game_manager, self.get_name())
		#2: self.algorithm = MCTSAlgorithm.new(game_manager.board, game_manager, self.get_name())
	#if self.algorithm:
		#self.add_child(self.algorithm)

# das ist die turn methdoe die einfach zum einen schaut ob ein feld ausgewählt wurde -> und zum andern dan je nach dem vom
# welchem spiler weis welcches elemnt sie auf dem brett anzeigen soll 	
func turn() -> void:
	#if self.selected_field == null:
		#self.selected_field = await self.algorithm.action()
	#else:
		#match self.get_name():
			#"Player1": spawn_element(selected_field, symbol_x)
			#"Player2": spawn_element(selected_field, symbol_o)
			#_: printerr("No player selected")
			#
		#self.selected_field.set_content(self.get_name())
		#self.game_manager.turn_counter += 1
		#self.selected_field = null
	if selected_field == null:
		selected_field = await algorithm.action()
	else:
		if self.get_name()=="Player1":
			spawn_element(selected_field, symbol_x)
		elif self.get_name()=="Player2":
			spawn_element(selected_field, symbol_o)
		else:
			printerr("kein Spieler")
			
		selected_field.set_content(self.get_name()) # sin der Feld Klassse 
		game_manager.turn_counter += 1 # runden counter +1
		
		selected_field = null # zurücksetzen des feldes 
		
		return

extends Node2D
class_name Player
		
		
@export var game_manger:Game_Manger
var play_algorithem:Controler
		
@onready var X = preload("res://Scenes/Tic-Tac_Toe_elements/X_character.tscn")
@onready var O = preload("res://Scenes/Tic-Tac_Toe_elements/O_character.tscn")
		
var selected_field:Field
		
## ich weiß ist nicht geill  bitte verändert nie mal die positionen der Scenen 
func _ready() -> void:
	pass
# elemnte sind hier X oder O
func spawn_element(field:Field,element:PackedScene):
	var instance = element.instantiate()
	field.add_child(instance)
		
func add_play_algoritem_to_player(play_algo):
	if play_algo == 0:
		print("Humen")
		play_algorithem = Human_Controler.new(game_manger.play_field,game_manger,self.get_name()) 
		self.add_child(play_algorithem)
		
	elif play_algo == 1:
		play_algorithem = Min_Miax.new(game_manger.play_field,game_manger,self.get_name())
		self.add_child(play_algorithem)
		
	elif play_algo == 2:
		print("MCTS")
		
	else:
		printerr("fehler")	
		
func remove_controler():
	self.get_child(0).queue_free()
		
func turn():
	if selected_field == null:
		selected_field = play_algorithem.action()
	else:
		if self.get_name()=="Player1":
			spawn_element(selected_field,O)
		elif self.get_name()=="Player2":
			spawn_element(selected_field,X)
		else:
			printerr("kein Spieler")
			
		selected_field.set_contet(self.get_name())
		game_manger.turn_counter += 1
		
		selected_field = null
		
		return

extends Node2D
class_name Player
		
		
@export var game_manger:Game_Manger # verweis auf game_manger
var play_algorithem: Controler # speciherort für den play_algorithem
@onready var X = preload("res://Scenes/Tic-Tac_Toe_elements/X_character.tscn") # packed scenes für X und O
@onready var O = preload("res://Scenes/Tic-Tac_Toe_elements/O_character.tscn")

# verwis auf das von dem mensch oder algo ausgewählten Feld 		
var selected_field:Field
		
		
func _ready() -> void:
	pass

# elemnte sind hier X oder O
func spawn_element(field:Field,element:PackedScene):
	var instance = element.instantiate()
	if len(field.get_children())<2:
		field.add_child(instance)

func add_play_algoritem_to_player(play_algo):
	if play_algo == 0:
		print("Human")
		play_algorithem = Human_Controler.new(game_manger.play_field, game_manger, self.get_name()) 
		self.add_child(play_algorithem)
		
	elif play_algo == 1:
		play_algorithem = Min_Miax.new(game_manger.play_field, game_manger, self.get_name())
		self.add_child(play_algorithem)
		
	elif play_algo == 2:
		play_algorithem = MCTS.new(game_manger.play_field,game_manger,self.get_name())
		self.add_child(play_algorithem)
		
	else:
		printerr("fehler")

# funktion die später vl noch wichtig ist wenn man runden übergreifent arbeiten will 		
func remove_controler():
	self.get_child(0).queue_free()
	
	
# das ist die turn methdoe die einfach zum einen schaut ob ein feld ausgewählt wurde -> und zum andern dan je nach dem vom
# welchem spiler weis welcches elemnt sie auf dem brett anzeigen soll 	
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
			
		selected_field.set_contet(self.get_name()) # sin der Feld Klassse 
		game_manger.turn_counter += 1 # runden counter +1
		
		selected_field = null # zurücksetzen des feldes 
		
		return

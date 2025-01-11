extends Node2D
class_name Controler

var playfield:Play_Field
var game_manager:Game_Manger

var player_name:String


# Konstruktor für jeden Algorithmus der noch kommen marg 
func _init(play_field:Play_Field,gamemanger:Game_Manger, playername:String ) -> void:
	self.playfield = play_field
	self.game_manager = gamemanger
	self.player_name = playername
	
# das ist die methdode in der am ende dan die aktion des ALgorithmus es ausgeführt wird 
# sie sollte immer ein " feld " als zuückgarbe an dei turn methdoe vom spiler geben 
func action():
	return 
	
# hier kann man dan die visualisierungs logik jedes algoritmuses rein scheiben 
func visualize_algorithm():
	pass
	
# schaut einfach ob es ein gewinner gibt oder unenscheiden ist ,  hatte ich für MinMAx gebarucht vl kann man es auch für MCTS benutzen 
func check_winner():
	var field = playfield.get_list_of_fields()
	var win_combinations = [[0,1,2],[3,4,5],[6,7,8],[2,4,6],[0,4,8],[0,3,6],[1,4,7],[2,5,8]]
	for combinations in win_combinations:
		var values:Array[Field] = []
		for pos in combinations:
			values.append(field[pos])
				
		if values[0].get_content() != "" and values[0].get_content() == values[1].get_content() and values[1].get_content() == values[2].get_content():
			return values[0].get_content() 
			
	for i in playfield.get_list_of_fields():
		# Prüfe, ob ein Feld leer ist
		if i.get_content() == "":
			# Wenn ein Feld leer ist, gibt es noch kein Unentschieden
			return null
	
			 
	return "draw"
	
	

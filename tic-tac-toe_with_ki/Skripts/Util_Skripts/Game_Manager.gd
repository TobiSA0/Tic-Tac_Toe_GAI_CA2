extends Node2D
class_name Game_Manger

## Soll als eine art schnitstelle zwischen den einzelenn Elementen dienen  daher muss jeder ALgorithmus auf den Game_Maager zugriff haben 
@onready var play_field:Play_Field = $Play_Field
@onready var game_hud:HUD = $UI_Layer/HUD
@onready var player1:Player = $Player1
@onready var player2:Player = $Player2

#flags
var game_is_done:bool = true
var game_is_set_up:bool = false
var game_is_reset:bool = true
var winner_of_round:String
var turn_counter = 1


func _ready() -> void:
	game_hud.connect("button_pressed",Callable(self,"_on_button_pressed"))
	game_hud.connect("reset_pressed",Callable(self,"_on_reset_pressed"))


func _on_button_pressed():
	if not game_is_set_up && game_is_reset:
		setup_game()
		game_is_done = false
		

func _on_reset_pressed():
	if game_is_done && not game_is_reset:
		get_tree().reload_current_scene()
		

# in der methdoe sollten wir es hinbekommen das dem speiler dan die richtige logic gesetzt wird 	
func setup_game():
	# erste zeile gibt den index der ausgewählten elemnte der OptionButtons im HUD skript 
	var selection = game_hud.get_selectet_players()
	player1.add_play_algoritem_to_player(selection[0])
	player2.add_play_algoritem_to_player(selection[1])
	
	game_is_set_up = true	

## schaut ob eine runde gewonnen ist 
func game_is_won():
	var field = play_field.get_list_of_fields()
	var win_combinations = [[0,1,2],[3,4,5],[6,7,8],[2,4,6],[0,4,8],[0,3,6],[1,4,7],[2,5,8]]
	for combinations in win_combinations:
		var values:Array[Field] = []
		for pos in combinations:
			values.append(field[pos])
			
				
		if values[0].get_content() != "" and values[0].get_content() == values[1].get_content() and values[1].get_content() == values[2].get_content():
			print("hi")
			winner_of_round = values[0].get_content()
			return true 
			 
	return false 
	
func _physics_process(delta: float) -> void:
	if game_is_set_up:
		if not game_is_won():
		
			if turn_counter % 2 != 0:
				player1.turn()
			else:
				player2.turn()	
				
		else:
			game_hud.set_ingame_text(winner_of_round+" is the Winner")
			game_is_reset = false
			game_is_done = true
			game_is_set_up = false
			
			

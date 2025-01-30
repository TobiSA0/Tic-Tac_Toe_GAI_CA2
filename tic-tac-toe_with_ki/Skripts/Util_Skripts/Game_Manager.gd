extends Node2D
class_name Game_Manger

## Game Manager ist eine art schnitt stelle auf die jedes elemnt zugruf hatt kinda , und in ihm befindet sich auch der Gameplay-Loop 


@onready var play_field:Play_Field = $Play_Field  # das ist der Verweiß auf das Spiel Feld 
@onready var game_hud:HUD = $UI_Layer/HUD # verweiß auf hud elemnte 
@onready var player1:Player = $Player1 # spiler 1
@onready var player2:Player = $Player2 # spieler 2
@onready var mcts_graph_window: Window = $MCTSGraphWindow

#flags hier kann man vl noch verbesserungen vornehemen aber es geht alos von da her 
var game_is_done:bool = true
var game_is_set_up:bool = false
var game_is_reset:bool = true
var winner_of_round:String

# zählt die runden ungerade ist spiler 1 gerade spieler 2
var turn_counter = 1


# hier werden events gestartet , die 2 buttons 
func _ready() -> void:
	game_hud.connect("button_pressed",Callable(self,"_on_button_pressed"))
	game_hud.connect("reset_pressed",Callable(self,"_on_reset_pressed"))
	game_hud.hide_ingame_test()
	game_hud.connect("graph_button_pressed",Callable(self,"_on_graph_button_pressed"))


# wenn jeweiliger button gedrückt dann arbeite damit  und führe aus was drin steht 
func _on_button_pressed():
	if not game_is_set_up && game_is_reset:
		setup_game()
		game_is_done = false
		
#logik für reset button
func _on_reset_pressed():
	if game_is_done && not game_is_reset:
		get_tree().reload_current_scene()

# hide graph window on x press
func _on_graph_button_pressed() -> void:
	if not mcts_graph_window.visible:
		mcts_graph_window.visible = true

## In dieser Methode werden  durch die Auwahl in den Option Button gewähltes elemnet gewählt  so weiß der spieler welchen Algo er
## verweden soll 	
func setup_game():
	# erste zeile gibt den index der ausgewählten elemnte der OptionButtons im HUD skript 
	var selection = game_hud.get_selectet_players()
	player1.add_play_algoritem_to_player(selection[0]) 
	player2.add_play_algoritem_to_player(selection[1])
	
	game_is_set_up = true

## schaut ob eine runde gewonnen ist indem es alle möglichen win kombinationen durch geht 
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


## schaue ob unentscheiden 	
func check_draw():
	# Iteriere durch alle Felder
	for field in play_field.get_list_of_fields():
		# Prüfe, ob ein Feld leer ist
		if field.get_content() == "":
			# Wenn ein Feld leer ist, gibt es noch kein Unentschieden
			return false
	# Wenn keine Felder leer sind, ist es ein Unentschieden
	return true


## gameloop
func _physics_process(delta: float) -> void:
	
	if game_is_set_up:
		if not game_is_won() && not check_draw():
			if turn_counter % 2 != 0:
				player1.turn()
			else:
				player2.turn()
				
		else:
			if game_is_won():
				game_hud.set_ingame_text(winner_of_round+" is the Winner")
			elif not check_draw():
				game_hud.set_ingame_text("Nobody is the Winner")
			else:
				game_hud.set_ingame_text("Draw!")
				
			game_is_reset = false
			game_is_done = true
			game_is_set_up = false
			

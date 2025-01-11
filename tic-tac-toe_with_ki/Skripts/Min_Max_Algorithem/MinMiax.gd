extends Controler
class_name Min_Miax


#ängt davon ab wer gerade als erstes startet 

func make_move():
	var best_score = INF
	var best_move = null
	
	for field in playfield.get_list_of_fields():
		if field is Field:
			
			if field.get_content() == "":
				field.set_contet(player_name)
				
				var score = minmax(playfield.get_list_of_fields(),0,true)
				
				field.set_contet("")
				
				if score < best_score:
					best_score = score
					best_move = field
				
	if best_move != null:
		return best_move
				
func minmax(board,depth, is_maximizing):
	var result = check_winner()
	
	if result != null:
		
		if result == player_name:
			return depth - 10
		elif result != player_name && result != "":
			return 10 - depth
		else:
			return 0
		
	# geht nur rein wen er spiler 1 zb human ist 	
	if is_maximizing:
		var best_score = -INF
		for field in playfield.get_list_of_fields():
			if field is Field:
				if field.get_content() == "":
					field.set_contet("Player1")
					var score = minmax(playfield.get_list_of_fields(),depth+1,false)
					field.set_contet("")
					best_score = max(best_score,score)
	
		return best_score
	
	else:
		var best_score = INF
		for field in playfield.get_list_of_fields():
			if field is Field:
				if field.get_content() == "":
					field.set_contet("Player2")
					var score = minmax(playfield.get_list_of_fields(),depth +1,true)
					field.set_contet("")
					best_score = min(best_score,score)
	
		return best_score
		
func action():
	return make_move()					
					
					

## ich muss no0ch alle scores spechern - dann in whaschelichkeit umrechnen , wenn das gehahn ist , pausire ich die _process methdoe und lasse alles anzeigen 		
			

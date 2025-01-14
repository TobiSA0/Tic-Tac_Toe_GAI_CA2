extends Controler
class_name Min_Miax


## zu dem hier das ist der min max in der basis - könnte sich noch überlegen, alpha bruning hinzuzufügen 
## aber mal schauen 

var timer:Timer
var field_scores = {}

var timer_is_done = false
var time_to_wait = 8

var is_in_progress:bool = false


var best_field = null


func _ready() -> void:
	timer = Timer.new()
	timer.connect("timeout",Callable(self,"_on_timer_timeout"))
	get_parent().add_child(timer)
	

func _on_timer_timeout():
	timer_is_done = true
	
func start_timer():
	timer.wait_time = time_to_wait
	timer.start()
	
	
	
func make_move():
	
	var best_score = INF
	var best_move = null
	
	for field in playfield.get_list_of_fields():
	
		if field.get_content() == "":
			field.set_contet(player_name)
			var score = minmax(playfield.get_list_of_fields(),0,true)	
			field.set_contet("")
			#print(score)
			field_scores[field] = score
				
			if score < best_score:
				best_score = score
				best_move = field

	#visualize_algorithm()

	if best_move != null:
		return best_move
	
# probelm hier ist einfach das er aus der rekursion nie raus geht weil er immer  durch die update methdoe von _process läuft idk why 
func minmax(board,depth, is_maximizing):
	var result = check_winner()
	if result != null:
		if result == player_name:
			return depth - 10
		elif result != player_name && result != "draw":
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
	#print("Action called: is_in_progress =", is_in_progress, ", best_field =", best_field)
	if not is_in_progress:
		is_in_progress = true
		best_field = make_move()
		return best_field
	
	else: 
		is_in_progress = false
		
	"""
	old code, logic not clear
	elif best_field != null:
		print("BEST FIELD")
		var temp = best_field
		is_in_progress = false
		best_field = null
		return temp
	"""
						
					
func visualize_algorithm():
	var total_score = 0
	print(field_scores.keys())

	for score in field_scores.values():
		total_score += abs(score) # absolute werte 
		#print(total_score)
	#for field in field_scores.keys():
		#if field is Field:
			#var probability = abs(field_scores[field])/total_score
			##print(probability)
			#field.set_label(str(probability))
			#field.show_label()
		
	

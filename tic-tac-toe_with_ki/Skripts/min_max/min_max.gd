extends Controller
class_name Min_Miax


var timer: Timer
var field_scores = {}
var timer_is_done = false
var time_to_wait = 0.1
var is_in_progress:bool = false
var best_field = null
var best_score = 0
var total_score = 0
var steps_queue = []  # Warteschlange für die Schritte (Felder und Aktionen)
var is_maximizing: bool = false
var hud:HUD

signal visualization_finished

func _ready() -> void:
	timer = Timer.new()
	timer.connect("timeout",Callable(self,"_on_timer_timeout"))
	get_parent().add_child(timer)
	hud = game_manager.game_hud
	is_maximizing = (player_name == "Player1")
	
func _on_timer_timeout():
	timer.stop()
	timer_is_done = true
	
func start_timer():
	timer.wait_time = time_to_wait
	timer.start()

func make_move():
	# Maximierung oder Minimierung basierend auf dem Spieler
	
	if is_maximizing:
		hud.set_ingame_text("Hey i will choose the Biggest Score")	
	else:
		hud.set_ingame_text("Hey i will choose the Smalest Score")
		
	
	best_score = - INF if is_maximizing else INF  # Initialisiere besten Score
	var best_move = null
	# arteschlange fuer Visualisierungsschritte leeren
	steps_queue.clear()
	# Iteriere alle Felder
	for field in board.get_list_of_fields():
		if field.get_content() == "":  # Nur leere Felder pruefen
			
			# Probiere den aktuellen Zug aus
			if is_maximizing:
				field.set_content("Player1")
			else:
				field.set_content("Player2")
				
			# Berechne den Score fuer dieses Feld
			var score = minmax(board.get_list_of_fields(), 0, not is_maximizing)
			field.set_content("")  # Setze das Feld zurueck
			
			print(score)
			field_scores[field] = score
			field.set_score(score)

			# Visualisiere nur das beste Feld
			if (is_maximizing and score > best_score) or (not is_maximizing and score < best_score):
				best_score = score
				best_move = field

			# Schritte zur Visualisierung hinzufuegen
			steps_queue.append({"field": field, "action": "highlight"})
			#field.set_score(get_probability_for_field(field))
			steps_queue.append({"field": field, "action": "reset"})
			
	
	hud.show_ingame_text()
	# Starte die Visualisierung
	if best_move != null:
		best_field = best_move
	process_visualization()
	# Warten, bis die Visualisierung abgeschlossen ist
	await self.visualization_finished
	# Gib das beste Feld zurueck
	if best_move != null:
		start_timer()
		return best_move
	else:
		# Kein gueltiger Zug gefunden
		return null

func minmax(board, depth, is_maximizing) -> int:
	var result = check_winner()
	if result != null:
		if is_maximizing:
			if result == player_name:
				return depth
			elif result != "draw":
				return depth - 10
			else:
				return 0
		else:
			if result == player_name:
				return depth - 5
			elif result != "draw":
				return 10 - depth
			else:
				return 0

	if is_maximizing:
		var best_score = -INF
		for field in board:
			if field is Field and field.get_content() == "":
				field.set_content("Player1")

				var score = minmax(board, depth + 1, false)
				field.set_content("")  # Feld zuruecksetzen

				best_score = max(best_score, score)
		return best_score
	else:
		var best_score = INF
		for field in board:
			if field is Field and field.get_content() == "":
				field.set_content("Player2")

				var score = minmax(board, depth + 1, true)
				field.set_content("")  # Feld zuruecksetzen

				best_score = min(best_score, score)
		return best_score


func action():
	#print("Action called: is_in_progress =", is_in_progress, ", best_field =", best_field)
	if not is_in_progress:
		is_in_progress = true
		
		if is_maximizing && game_manager.turn_counter == 1:
			var random_field = randi()%9+1
			var playfield = board.get_list_of_fields()
			is_in_progress = false
			return playfield[random_field]
			
		else:
			
			print("hello")
			best_field = await make_move()
		
	if timer_is_done:
		is_in_progress = false
		timer_is_done = false
		board.hide_visualization()
		field_scores = {}
		hud.hide_ingame_text()
		return best_field


func process_visualization():
	if steps_queue.size() > 0:
		var step = steps_queue.pop_front()  # Nimm den ersten Schritt aus der Warteschlange
		var field = step["field"]
		var action = step["action"]
		var score = field.get_score()
		
		field.set_label(str(score))
		 
		field.show_label()
		if action == "highlight":
			if field == best_field:
				field.set_highlight(true, Color(0, 1, 0))  # Feld hervorheben
			else: 
				field.set_highlight(true)
		elif action == "reset" and not (field == best_field):
			field.set_highlight(false)  # Highlight zuruecksetzen

		# Starte den nÃ¤chsten Schritt nach einer kurzen Pause
		get_tree().create_timer(0.3).timeout.connect(process_visualization)
	else:
		emit_signal("visualization_finished")

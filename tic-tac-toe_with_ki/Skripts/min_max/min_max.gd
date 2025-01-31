class_name MinMax
extends Controller

## zu dem hier das ist der min max in der basis - könnte sich noch überlegen, alpha bruning hinzuzufügen 
## aber mal schauen 

var best_field: Field = null
var best_score: int = 0
var field_scores: Dictionary = {}
var is_in_progress: bool = false
var is_maximizing: bool = false
var steps_queue: Array = []  # Warteschlange für die Schritte (Felder und Aktionen)
var timer: Timer
var timer_is_done: bool = false
var time_to_wait: float = 0.1
var total_score: int = 0
var hud: HUD

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
		self.hud.set_ingame_text("Choosing the biggest score")
	else:
		self.hud.set_ingame_text("Choosing the smallest score")
	best_score = - INF if is_maximizing else INF  # Initialisiere besten Score
	var best_move = null
	# Warteschlange für Visualisierungsschritte leeren
	steps_queue.clear()
	# Iteriere über alle Felder
	for field in board.get_list_of_fields():
		if field.get_content() == "":  # Nur leere Felder prüfen
			
			# Probiere den aktuellen Zug aus
			if is_maximizing:
				field.set_content("Player1")
			else:
				field.set_content("Player2")
				
			# Berechne den Score für dieses Feld
			var score = minmax(board.get_list_of_fields(), 0, not is_maximizing)
			field.set_content("")  # Setze das Feld zurück
			
			print(score)
			field_scores[field] = score
			field.set_score(score)

			# Visualisiere nur das beste Feld
			if (is_maximizing and score > best_score) or (not is_maximizing and score < best_score):
				best_score = score
				best_move = field

			# Schritte zur Visualisierung hinzufügen
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
	# Gib das beste Feld zurück
	if best_move != null:
		start_timer()
		return best_move
	else:
		# Kein gültiger Zug gefunden
		return null

func minmax(board2, depth, is_maximizing) -> int:
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
		for field in board2:
			if field is Field and field.get_content() == "":
				field.set_content("Player1")

				var score = minmax(board2, depth + 1, false)
				field.set_content("")  # Feld zurücksetzen

				best_score = max(best_score, score)
		return best_score
	else:
		var best_score = INF
		for field in board2:
			if field is Field and field.get_content() == "":
				field.set_content("Player2")

				var score = minmax(board2, depth + 1, true)
				field.set_content("")  # Feld zurücksetzen

				best_score = min(best_score, score)
		return best_score


func action():
	if not is_in_progress:
		is_in_progress = true
		
		if is_maximizing and game_manager.turn_counter == 1:
			var random_field = randi() % 9 + 1
			var board = board.get_list_of_fields()
			is_in_progress = false
			return board[random_field]
			
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

func calc_total_fields_score():  # brauchen wir nicht mehr 
	total_score = 0
	for score in field_scores.values():
		total_score += abs(score)

func get_probability_for_field(field: Field): # brauchen wir nicht mehr 
	calc_total_fields_score()
	# print("Field Score: ", field_scores[field])
	var probability = float(field_scores[field])/total_score * 100 if total_score != 0 else 0
	var rounded_probability = (round(probability * 100) / 100.0) as int
	return rounded_probability

func process_visualization():
	if steps_queue.size() > 0:
		var step = steps_queue.pop_front()  # Nimm den ersten Schritt aus der Warteschlange
		var field = step["field"]
		var action = step["action"]
		var score = field.get_score()
		if score == 0:
			field.set_label("DRAW")
		else:
			field.set_label(str(score))
		 
		field.show_label()
		if action == "highlight":
			if field == best_field:
				field.set_highlight(true, Color(0, 1, 0))  # Feld hervorheben
			else: 
				field.set_highlight(true)
		elif action == "reset" and not (field == best_field):
			field.set_highlight(false)  # Highlight zurücksetzen

		# Starte den nächsten Schritt nach einer kurzen Pause
		get_tree().create_timer(0.3).timeout.connect(process_visualization)
	else:
		emit_signal("visualization_finished")  # Signal auslösen

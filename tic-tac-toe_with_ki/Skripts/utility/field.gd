class_name Field
extends Node2D

# hier speicher ich intern ob es ein X oder ein O ist als string ist einfacher als immer nur nach den Assets zu gehen  
@onready var label: Label = $Label
var symbol: String = ""  
var score: float = 0.0

# getter methdoe um auf den inhalt zugriff zu haben 
func get_content() -> String:
	return symbol

# setter _ schaut welcher spieler und setzt dan x oder O  -> 0 is bei und spiler 1 
func set_content(player_name: String) -> void:
	if player_name == "Player1":
		symbol = "X"
	elif player_name == "Player2":
		symbol = "O"
	else:
		symbol = ""

func set_score(score: float) -> void:
	self.score = score

func get_score() -> float:
	return score

func set_highlight(highlight: bool, color: Color = Color(1, 0, 0)) -> void:
	if highlight:
		self.get_child(0).modulate = color # rot einfärben
	else:
		self.get_child(0).modulate = Color(1, 1, 1) # Zurücksetzen auf Standardfarbe

func set_label(value:String) -> void:
	label.text = value 

func get_label_text() -> String:
	return label.text

func show_label() -> void:
	label.show()
	
func hide_label() -> void:
	label.hide()

#löscht alle elemnte also X und O ( allso die bilder ) aus der Scene (was noch verbesster werden muss )
func clear_field() -> void:
	for child in get_children():
		if child is Node2D:
			child.queue_free()

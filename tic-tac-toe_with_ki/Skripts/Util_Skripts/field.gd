extends Node2D
class_name Field

# hier speicher ich intern ob es ein X oder ein O ist als string ist einfacher als immer nur nach den Assets zu gehen  
var content: String = ""  
var score: float = 0.0

@onready var label: Label = $Label

# getter methdoe um auf den inhalt zugriff zu haben 
func get_content()-> String:
	return content

# seter _ schaut welcher spieler und setzt dan x oder O  -> 0 is bei und spiler 1 
func set_content(player:String):
	if player == "Player1":
		content = "O"
	elif player == "Player2":
		content = "X"
	else:
		content = ""

func set_score(score: float):
	self.score = score
	
func get_score():
	return score

func set_highlighted(highlight: bool, color: Color = Color(1, 0, 0)) -> void:
	if highlight:
		self.get_child(0).modulate = color # rot einfärben
	else:
		self.get_child(0).modulate = Color(1, 1, 1) # Zurücksetzen auf Standardfarbe

func set_label(value:String):
	label.text = value 
	
func get_label_text():
	return label.text

func show_label():
	label.show()
	
func hide_label():
	label.hide()

#löscht alle elemnte also X und O ( allso die bilder ) aus der Scene (was noch verbesster werden muss )
func clear_field():
	for child in get_children():
		if child is Node2D:
			child.queue_free()
			

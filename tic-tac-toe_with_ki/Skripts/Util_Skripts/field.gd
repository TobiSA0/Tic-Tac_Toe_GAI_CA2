extends Node2D
class_name Field

# hier speicher ich intern ob es ein X oder ein O ist als string ist einfacher als immer nur nach den Assets zu gehen  
var content:String = ""  

# verweiß auf das label 
@onready var label:Label = $Label

#getter methdoe um auf den inhalt zugriff zu haben 
func get_content()-> String:
	return content

# seter _ schaut welcher spieler und setzt dan x oder O  -> 0 is bei und spiler 1 
func set_contet(player:String):
	if player == "Player1":
		content = "O"
	elif player == "Player2":
		content = "X"
	else:
		content = ""

# hier könnte man dan auch noch theoretisch die Farbe setzten 
func set_label(value:String):
	#label.label_settings.font_color = Color.RED - BSP wie man dort dan auch die Farbe Setzen kann und größe ( erst am ende ) 
	label.text = value + "%"
	
# anzeigen 
func show_label():
	label.show()
	
# verstecken 
func hide_label():
	label.hide()

#löscht alle elemnte also X und O ( allso die bilder ) aus der Scene (was noch verbesster werden muss )
func clear_field():
	for child in get_children():
		if child is Node2D:
			child.queue_free()
			

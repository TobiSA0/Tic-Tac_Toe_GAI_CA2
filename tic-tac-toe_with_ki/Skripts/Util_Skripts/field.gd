extends Node2D
class_name Field

var content:String = ""
@onready var label:Label = $Label

func get_content()-> String:
	return content

func set_contet(player:String):
	if player == "Player1":
		content = "O"
	elif player == "Player2":
		content = "X"
	else:
		printerr("Kein Spieler")

# hier könnte man dan auch noch theoretisch die Farbe setzten 
func set_label(value:String):
	#label.label_settings.font_color = Color.RED - BSP wie man dort dan auch die Farbe Setzen kann und größe ( erst am ende ) 
	label.text = value + "%"
	
func show_label():
	label.show()
	
func hide_label():
	label.hide()
	
func clear_field():
	for child in get_children():
		if child is Node2D:
			child.queue_free()
			

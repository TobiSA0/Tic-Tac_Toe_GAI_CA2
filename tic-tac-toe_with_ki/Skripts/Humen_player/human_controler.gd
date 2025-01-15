extends Controler
class_name Human_Controler

func action():
	#print("Hi bin jekt in aktion")
	if Input.is_action_just_pressed("input_press"):
		for field in playfield.get_list_of_fields():
			if field is Field and len(field.get_children())<2:
				var direction = field.position - playfield.to_local(get_global_mouse_position())
				var distance = direction.length()
				if distance <= 80:
					return field
		return null
	
	

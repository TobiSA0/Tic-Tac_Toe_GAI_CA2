class_name HumanPlayer
extends Controller

# 
func action():
	if Input.is_action_just_pressed("input_press"):
		for field in self.board.get_list_of_fields():
			if field is Field and len(field.get_children()) < 2:
				var direction: Vector2 = field.position - board.to_local(get_global_mouse_position())
				var distance: float = direction.length()
				if distance <= 80:
					return field
		return null

extends Node2D
class_name Play_Field

@onready var field_points:Node2D = $Field_Points

func _ready() -> void:
	hide_visualization()
	
# dast ist der array der einzelnen felder  max 9 
func get_list_of_fields()->Array[Node]:
	return field_points.get_children()

func clear_playfeild():
	for field in field_points.get_children():
		if field is Field:
			field.clear_field()
	
func hide_visualization():
	for field in field_points.get_children():
		if field is Field:
			field.hide_label()

func show_visualization():
	for field in field_points.get_children():
		if field is Field and field.content == "" and field.get_label_text() != "%":
			field.show_label()

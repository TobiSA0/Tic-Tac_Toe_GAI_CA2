class_name Board
extends Node2D

@onready var fields: Node2D = $Fields

func _ready() -> void:
	hide_visualization()
	
# dast ist der array der einzelnen felder  max 9
func get_list_of_fields() -> Array[Node]:
	return fields.get_children()

func clear_playfeild():
	for field in fields.get_children():
		if field is Field:
			field.clear_field()
	
func hide_visualization():
	for field in fields.get_children():
		if field is Field:
			field.hide_label()

func show_visualization():
	for field in fields.get_children():
		if field is Field and field.content == "" and field.get_label_text() != "%":
			field.show_label()

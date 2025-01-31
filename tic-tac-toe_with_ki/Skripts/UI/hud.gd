extends Control
class_name HUD

signal button_pressed
signal graph_button_pressed
signal reset_pressed

@onready var player_selector_one: OptionButton = $Selector1
@onready var player_selector_two: OptionButton = $Selector2
@onready var iteration_line_edit_one: LineEdit = $LineEdit1
@onready var iteration_line_edit_two: LineEdit = $LineEdit2
@onready var button: Button = $PlayButton
@onready var reset_button: Button = $ResetButton
@onready var graph_window_button: Button = $MCTSGraphWindowButton
@onready var ingame_text_label: Label = $IngameText

func _ready() -> void:
	button.pressed.connect(_on_play_button_pressed)
	reset_button.pressed.connect(_on_reset_button_pressed)
	graph_window_button.pressed.connect(_on_graph_button_pressed)
	player_selector_one.item_selected.connect(func(index: int): _on_option_selected(index, player_selector_one))
	iteration_line_edit_one.text_changed.connect(func(text: String): _on_text_changed(text, iteration_line_edit_one))
	player_selector_two.item_selected.connect(func(index): _on_option_selected(index, player_selector_two))
	iteration_line_edit_two.text_changed.connect(func(text: String): _on_text_changed(text, iteration_line_edit_two))

# butten triggert eine falg woi ich inb process danch schue
func _on_play_button_pressed():
	emit_signal("button_pressed")

func _on_reset_button_pressed():
	emit_signal("reset_pressed")

func _on_graph_button_pressed():
	emit_signal("graph_button_pressed")

func _on_option_selected(index: int, option_button: OptionButton) -> void:
	match option_button.name:
		"Selector1": iteration_line_edit_one.visible = true if index == 2 else false
		"Selector2": iteration_line_edit_two.visible = true if index == 2 else false

func _on_text_changed(new_text: String, line_edit: LineEdit) -> void:
	var old_caret_position: int = line_edit.caret_column
	var word: String = ""
	var regex = RegEx.new()
	# allow only numbers 0-9
	regex.compile("[0-9]")
	# if non number character is entered
	var diff: int = regex.search_all(new_text).size() - new_text.length()
	for valid_character in regex.search_all(new_text):
		word += valid_character.get_string()
	line_edit.set_text(word)
	line_edit.caret_column = old_caret_position + diff

## Geneal class for all important HUD Elemnets
func get_selected_players()-> Array[int]:
	var players:Array[int]
	players.append(player_selector_one.get_selected_id())
	players.append(player_selector_two.get_selected_id())
	return players

func set_ingame_text(text: String) -> void:
	ingame_text_label.text = text

func show_ingame_text() -> void:
	ingame_text_label.show()

func hide_ingame_text() -> void:
	ingame_text_label.hide()

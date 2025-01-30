extends Control
class_name HUD

signal button_pressed
signal graph_button_pressed
signal reset_pressed

@onready var player_selector_one:OptionButton = $Selector_1
@onready var player_selector_two:OptionButton = $Selector_2
@onready var iteration_line_edit_two: LineEdit = $Selector2Iterations
@onready var button = $Play_Button
@onready var reset_button = $Reset_Button
@onready var graph_window_button = $Graph_Window_Button
@onready var ingame_test_label = $Ingame_text

func _ready() -> void:
	button.connect("pressed",Callable(self,"_on_play_button_pressed"))
	reset_button.connect("pressed",Callable(self,"_on_reset_button_pressed"))
	graph_window_button.connect("pressed",Callable(self,"_on_graph_button_pressed"))
	player_selector_two.item_selected.connect(on_option_selected)
	iteration_line_edit_two.text_changed.connect(on_text_changed)

func on_option_selected(index: int) -> void:
	if index != 2:  # Ersetze mit deinem gewünschten Wert
		iteration_line_edit_two.visible = false  # Zeige das LineEdit-Feld an
	else:
		iteration_line_edit_two.visible = true  # Verstecke das LineEdit-Feld

func on_text_changed(new_text: String) -> void:
	var old_caret_position: int = iteration_line_edit_two.caret_column
	var word: String = ""
	var regex = RegEx.new()
	# allow only numbers 0-9
	regex.compile("[0-9]")
	# if non number character is entered
	var diff: int = regex.search_all(new_text).size() - new_text.length()
	for valid_character in regex.search_all(new_text):
		word += valid_character.get_string()
	iteration_line_edit_two.set_text(word)
	iteration_line_edit_two.caret_column = old_caret_position + diff

## Geneal class for all important HUD Elemnets
func get_selectet_players()-> Array[int]:
	var players:Array[int]
	players.append(player_selector_one.get_selected_id())
	players.append(player_selector_two.get_selected_id())
	
	return players
	
func set_ingame_text(text:String)->void:
	ingame_test_label.text = text
	
func show_ingame_text()->void:
	ingame_test_label.show()
	
func hide_ingame_test()->void:
	ingame_test_label.hide()
	
# butten triggert eine falg woi ich inb process danch schue 
func _on_play_button_pressed():
	emit_signal("button_pressed")
	
func _on_reset_button_pressed():
	emit_signal("reset_pressed")

func _on_graph_button_pressed():
	emit_signal("graph_button_pressed")

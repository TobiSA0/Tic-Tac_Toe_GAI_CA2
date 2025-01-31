extends Control
class_name HUD

@onready var player_selector_one: OptionButton = $Selector1
@onready var player_selector_two: OptionButton = $Selector2
@onready var iteration_line_edit_one: LineEdit = $LineEdit1
@onready var iteration_line_edit_two: LineEdit = $LineEdit2
@onready var play_button: Button = $PlayButton
@onready var reset_button: Button = $ResetButton
@onready var graph_window_one: Window = $"../../MCTSGraphEditWindow1"
@onready var graph_window_two: Window = $"../../MCTSGraphEditWindow2"
@onready var graph_window_button_one: Button = $MCTSGraphWindowButton1
@onready var graph_window_button_two: Button = $MCTSGraphWindowButton2
@onready var ingame_text_label: Label = $IngameText
@onready var max_info_label: Label = $maxi_info
@onready var min_info_label: Label = $mini_info

signal play_button_pressed
signal graph_button_pressed
signal reset_button_pressed

func _ready() -> void:
	# hide and disable labels and buttons
	self.max_info_label.hide()
	self.min_info_label.hide()
	self.iteration_line_edit_one.hide()
	self.iteration_line_edit_two.hide()
	self.graph_window_button_one.disabled = true
	self.graph_window_button_two.disabled = true
	self.reset_button.disabled = true
	# connect signals
	self.play_button.pressed.connect(_on_play_button_pressed)
	self.reset_button.pressed.connect(_on_reset_button_pressed)
	self.graph_window_button_one.pressed.connect(func(): _on_graph_button_pressed(1))
	self.graph_window_button_two.pressed.connect(func(): _on_graph_button_pressed(2))
	self.player_selector_one.item_selected.connect(func(index: int): _on_option_selected(index, self.player_selector_one))
	self.player_selector_two.item_selected.connect(func(index: int): _on_option_selected(index, self.player_selector_two))
	self.iteration_line_edit_one.text_changed.connect(func(text: String): _on_text_changed(text, self.iteration_line_edit_one))
	self.iteration_line_edit_two.text_changed.connect(func(text: String): _on_text_changed(text, self.iteration_line_edit_two))

# play button
func _on_play_button_pressed():
	emit_signal("play_button_pressed")

# reset button
func _on_reset_button_pressed():
	emit_signal("reset_button_pressed")

# pop up graph window on corresponding button press
func _on_graph_button_pressed(index: int):
		match index:
			1:
				if not self.graph_window_one.visible:
					self.graph_window_one.visible = true
			2:
				if not self.graph_window_two.visible:
					self.graph_window_two.visible = true

func _on_option_selected(index: int, option_button: OptionButton) -> void:
	match option_button.name:
		"Selector1":
			match index:
				0: # human
					self.max_info_label.visible = false
					self.iteration_line_edit_one.visible = false
					# to enable play button in case other selector is mcts and has 1000+ iterations entered
					if self.player_selector_two.selected == 2:
						_on_text_changed(self.iteration_line_edit_two.text, self.iteration_line_edit_two)
				1: # minmax
					self.max_info_label.visible = true
					self.iteration_line_edit_one.visible = false
					# to enable play button in case other selector is mcts and has 1000+ iterations entered
					if self.player_selector_two.selected == 2:
						_on_text_changed(self.iteration_line_edit_two.text, self.iteration_line_edit_two)
				2: # mcts
					self.max_info_label.visible = false
					self.iteration_line_edit_one.visible = true
					if (int(self.iteration_line_edit_one.text) < 1000) or (self.iteration_line_edit_two.visible and int(self.iteration_line_edit_two.text) < 1000):
						self.play_button.disabled = true
		"Selector2":
			match index:
				0: # human
					self.min_info_label.visible = false
					self.iteration_line_edit_two.visible = false
					# to enable play button in case other selector is mcts and has 1000+ iterations entered
					if self.player_selector_one.selected == 2:
						_on_text_changed(self.iteration_line_edit_one.text, self.iteration_line_edit_one)
				1: # minmax
					self.min_info_label.visible = true
					self.iteration_line_edit_two.visible = false
					# to enable play button in case other selector is mcts and has 1000+ iterations entered
					if self.player_selector_one.selected == 2:
						_on_text_changed(self.iteration_line_edit_one.text, self.iteration_line_edit_one)
				2: # mcts
					self.min_info_label.visible = false
					self.iteration_line_edit_two.visible = true
					if (int(self.iteration_line_edit_two.text) < 1000) or (self.iteration_line_edit_one.visible and int(self.iteration_line_edit_one.text) < 1000):
						self.play_button.disabled = true

func _on_text_changed(new_text: String, line_edit: LineEdit) -> void:
	var other_line_edit: LineEdit = self.iteration_line_edit_one if line_edit == self.iteration_line_edit_two else self.iteration_line_edit_two
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
	if int(new_text) > 999:
		if not other_line_edit.visible or int(other_line_edit.text) > 999:
			self.play_button.disabled = false
	else:
		self.play_button.disabled = true
	

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

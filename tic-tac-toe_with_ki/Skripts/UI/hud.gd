extends Control
class_name HUD

signal button_pressed

signal reset_pressed

@onready var player_selector_one:OptionButton = $Selector_1
@onready var player_selector_two:OptionButton = $Selector_2
@onready var button = $Play_Button
@onready var reset_button = $Reset_Button
@onready var ingame_test_label = $Ingame_text

func _ready() -> void:
	button.connect("pressed",Callable(self,"_on_play_button_pressed"))
	reset_button.connect("pressed",Callable(self,"_on_reset_button_pressed"))
	
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

extends Node2D
class_name Controler

var playfield:Play_Field

func _init(play_field:Play_Field) -> void:
	self.playfield = play_field

# das ist die methdode in der am ende dan die aktion des ALgorithmus es ausgeführt wird 
func action():
	return 
	
# hier kann man dan die visualisierungs logik jedes algoritmuses rein scheiben 
func visualize_algorithm_validation():
	pass

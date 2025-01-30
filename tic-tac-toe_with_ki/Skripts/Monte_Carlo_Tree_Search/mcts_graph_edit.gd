class_name MctsGraphEdit
extends GraphEdit

const DEBUG: bool = false

var mcts: MCTS
# dictionary to count children per layer
var layer_dictionary: Dictionary = {
	0: 0,
	1: 0,
	2: 0,
	3: 0,
	4: 0,
	5: 0,
	6: 0,
	7: 0,
	8: 0,
}
# dictionary to count rows per layer
var row_dictionary: Dictionary = {
	0: 0,
	1: 0,
	2: 0,
	3: 0,
	4: 0,
	5: 0,
	6: 0,
	7: 0,
	8: 0,
}

#
func _ready() -> void:
	self.get_parent().connect("close_requested", _on_window_close)

# 
func align_nodes() -> void:
	#print("test: ", len(self.get_children()))
	if self.mcts:
		var root_layer: int = mcts.root.layer
		# count children per layer
		for child in self.get_children():
			if child is TreeNode and child.parent:
				self.layer_dictionary[child.layer] += 1
		# position children and count the rows
		for child in self.get_children():
			if child is TreeNode and child.parent:
				child.position_self(self.layer_dictionary[child.layer], self.row_dictionary[child.layer], root_layer)
				self.row_dictionary[child.layer] += 1
		for key in row_dictionary:
			row_dictionary[key] = 0
			layer_dictionary[key] = 0

# 
func reset_tree_nodes() -> void:
	# reset child counter
	self.child_counter = 0
	# destroy all TreeNodes
	for child in self.get_children():
		if child is TreeNode:
			child.free()
	# reset dictionaries and array
	for key in layer_dictionary:
		layer_dictionary[key] = 0

#
func _on_window_close() -> void:
	self.get_parent().hide()

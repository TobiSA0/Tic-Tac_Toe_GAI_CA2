class_name MctsGraphEdit
extends GraphEdit

const TREE_NODE = preload("res://Scenes/tree_node.tscn")
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
var child_counter: int = 0
var children: Array[TreeNode] = []

func add_node(tree_node: TreeNode):
	if tree_node:
		self.add_child(tree_node)
		self.child_counter += 1
		tree_node.title = str(self.child_counter)
		children.append(tree_node)
	print("counter: ", self.child_counter)

func align_nodes() -> void:
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
	for child in children:
		if child is TreeNode:
			layer_dictionary[child.layer] += 1
	for child in children:
		if child is TreeNode:
			child.position_self(layer_dictionary[child.layer], row_dictionary[child.layer])
			row_dictionary[child.layer] += 1

# 
func clear_nodes() -> void:
	self.child_counter = 0
	for item in layer_dictionary:
		layer_dictionary[item] = 0
	for child in self.get_children():
		if child is TreeNode:
			child.queue_free()

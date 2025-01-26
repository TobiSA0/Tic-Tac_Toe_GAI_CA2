class_name MctsGraph
extends GraphEdit

const TREE_GRAPH_NODE = preload("res://Scenes/tree_graph_node.tscn")
# Ein Dictionary, um TreeNode-Objekte mit GraphNode-IDs zu verknüpfen
#var node_map: Dictionary
#var root_node: TreeNode
var child_counter: int = 0

#func _init(root_node: TreeNode = null):
	#self.root_node = root_node
	#self.node_map = {}

func add_graph_node(tree_node: TreeNode):
	var graph_node: TreeGraphNode = TREE_GRAPH_NODE.instantiate()
	# connect TreeNode with corresponding TreeNodeGraph
	graph_node.connect_tree_node(tree_node)
	# sync other attributes from tree_node to graph_node
	#graph_node.sync_with_tree_node()
	
	graph_node.title = str(self.child_counter)
	self.add_child(graph_node)
	graph_node.connect_to_parent()
	#self.align_nodes()
	#graph_node.position_self()
	self.child_counter += 1
	print("counter: ", self.child_counter)
	
	
	
	#graph_node.title = "Title: " + str(self.child_counter)
	#graph_node.name = str(self.child_counter)
	#graph_node.position_offset = position
	#graph_node.size = Vector2(200, 200)
	
	# Füge den Knoten zur Karte hinzu
	#node_map[graph_node.name] = graph_node.tree_node
	
	# Verbinde den aktuellen Knoten mit seinem Elternknoten
	#if graph_node.parent:
		#graph_node.connect_to_parent()
		#graph_node.parent.set_slot(0, false, 0, Color.WHITE, true, 0, Color.WHITE)
		#graph_node.set_slot(0, true, 0, Color.WHITE, false, 0, Color.WHITE)
		#self.connect_node(graph_node.parent.name, 0, graph_node.name , 0)
		#self.connect_node(parent_graph_node.name, 1, graph_node.name , 1)
		#print("A: ", graph_node.get_input_port_count(), ", ", graph_node.parent.get_input_port_count())
		#print("B: ", graph_node.get_output_port_count(), ", ", graph_node.parent.get_output_port_count())
	
	# Rekursiv Kinder hinzufügen
	#var x: int = graph_node.position.x + 800
	#var y: int
	#var child_counter: int = 0
	#for child in tree_node.children:
		#y = graph_node.position.y + (child_counter * 800)
		#child_counter += 1
		#var child_position = Vector2(x, y)  # Verschiebe die Kinderknoten
		#add_graph_node(child, graph_node, child_position)

func align_nodes() -> void:
	var layer_counter: int = 1
	var nodes_array: Array[TreeGraphNode] = []
	#print("LUL: ", len(self.get_children()))
	for child in self.get_children():
		#print("Child: ", child)
		if child is TreeGraphNode:
			# root node
			if child.tree_node.layer == 0:
				child.position_offset = Vector2(0, 0)
			# non root nodes
			else:
				if layer_counter != child.tree_node.layer:
					var child_number: int = 0
					for element in nodes_array:
						var a = element.tree_node.layer
						print("layer: ", a)
						var x: int = element.tree_node.layer * 400
						var y: int = element.calculate_y_position(len(nodes_array), child_number)
						element.position_offset = Vector2(x, y)
						child_number += 1
					layer_counter += 1
					nodes_array = []
				nodes_array.append(child)
				
	# last layer
	var child_number: int = 0
	for element in nodes_array:
		var a = element.tree_node.layer
		print("layer: ", a)
		var x: int = element.tree_node.layer * 400
		var y: int = element.calculate_y_position(len(nodes_array), child_number)
		element.position_offset = Vector2(x, y)
		child_number += 1
	layer_counter += 1
	nodes_array = []

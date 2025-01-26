class_name TreeGraphNode
extends GraphNode

#var board: Array[String]
#var children: Array[TreeGraphNode]
#var expanded_moves: Array[int]
#var is_fully_expanded: bool
#var is_terminal: bool
#var layer: int
var mcts_graph: MctsGraph
var parent: TreeGraphNode
#var possible_moves: Array[int]
#var score: float
var tree_node: TreeNode
#var visits: float


# runs when GraphEdit instantiates new TreeGraphNode scene
func _init() -> void:
	# slot with index 0 for left side (input) and for right side (output)
	self.set_slot(0, true, 0, Color.WHITE, true, 0, Color.WHITE)

# runs when GraphEdit adds this instance as child
func _ready() -> void:
	self.mcts_graph = self.get_parent()
	if self.tree_node.parent:
		self.parent = self.tree_node.parent.graph_node
		#self.parent.children.append(self)
	print("TreeGraphNode _ready")

# connect TreeGraphNode its parent TreeGraphNode
func connect_to_parent() -> void:
	if self.parent:
		print("Connecting to parent...")
		# connect left side of parent to right side of self
		self.mcts_graph.connect_node(self.parent.name, 0, self.name, 0)
	else:
		print("No parent to connect to...")

# position withing the GraphEdit to make graph somewhat symmetrical
func position_self() -> void:
	# position TreeGraphNode corresponding to its layer and its parents children count
	if self.tree_node.parent:
		#var x = self.tree_node.layer * 400
		#var y = len(self.tree_node.parent.children) * 400
		#self.position_offset = Vector2(x, y)
		self.position_offset = Vector2(self.tree_node.layer * 400, self.mcts_graph.child_counter * 200)
	else: 
		self.position_offset = Vector2(0, 0)

# 
func connect_tree_node(tree_node: TreeNode) -> void:
	self.tree_node = tree_node
	tree_node.graph_node = self
	for child in self.get_children():
		child.text = str(tree_node.layer)
	#self.board = tree_node.board
	#self.expanded_moves = tree_node.expanded_moves
	#self.is_fully_expanded = tree_node.is_fully_expanded
	#self.is_terminal = tree_node.is_terminal
	#self.layer = tree_node.layer
	#self.mcts_graph = tree_node.mcts_graph
	#self.parent = tree_node.tree_graph_node
	#self.possible_moves = tree_node.possible_moves
	#self.score = tree_node.score
	#self.tree_node = tree_node.tree_node
	#self.visits = tree_node.visits

# 
#func sync_with_tree_node() -> void:
	#self.board = self.tree_node.board
	#self.expanded_moves = self.tree_node.expanded_moves
	#self.is_fully_expanded = self.tree_node.is_fully_expanded
	#self.is_terminal = self.tree_node.is_terminal
	#self.layer = self.tree_node.layer
	#self.mcts_graph = self.tree_node.mcts_graph
	#self.parent = self.tree_node.tree_graph_node
	#self.possible_moves = self.tree_node.possible_moves
	#self.score = self.tree_node.score
	#self.tree_node = self.tree_node.tree_node
	#self.visits = self.tree_node.visits

# 
func calculate_y_position(amount_nodes: int, child_number: int) -> int:
	var parent_y: int = self.tree_node.parent.graph_node.position.y
	var y_range: int = (amount_nodes * (self.size.y * 2)) - (self.size.y * 2)
	var upper_y: int = (y_range / 2) * -1
	var lower_y: int = y_range / 2
	var result: int = upper_y + (child_number * (self.size.y * 2))
	#print("")
	return result

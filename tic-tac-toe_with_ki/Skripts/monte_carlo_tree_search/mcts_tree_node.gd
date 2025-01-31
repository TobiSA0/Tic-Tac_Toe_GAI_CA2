class_name MCTSTreeNode
extends GraphNode

const DEBUG: bool = false

@onready var board_grid: GridContainer
@onready var children_expanded: bool = false
@onready var layer_label: Label
@onready var score_label: Label
@onready var visits_label: Label
@onready var toggle_button: Button

# attributes
var board: Array[String]:
	set(value):
		board = value
		for child in board_grid.get_children():
			if value[int(str(child.name))] != "":
				child.text = value[int(str(child.name))]
var children: Array[MCTSTreeNode]
var expanded_moves: Array[int]
var is_fully_expanded: bool
var is_terminal: bool
var layer: int:
	set(value):
		layer = value
		layer_label.text = "Layer: " + str(value)
var mcts_graph_edit: MCTSGraphEdit
var move_index: int
var parent: MCTSTreeNode
var possible_moves: Array[int]
var score: float:
	set(value):
		score = value
		score_label.text = "Score: " + str(value)
var visits: float:
	set(value):
		visits = value
		visits_label.text = "Visits: " + str(value)

# runs when new MCTSTreeNode scene is instantiated
func _init() -> void:
	# add slots with index 0 for left side (input) and for right side (output)
	self.set_slot(0, true, 0, Color.WHITE, true, 0, Color.WHITE)

# expand/collapse TreeNode children
func _on_toggle_pressed():
	#children_expanded = not children_expanded
	#toggle_button.text = "-" if children_expanded else "+"
	toggle_descendants(not children_expanded)

#
func add_values(board: Array[String], parent: MCTSTreeNode, move_index: int) -> void:
	self.board_grid = $Board
	self.layer_label = $Layer
	self.score_label = $Score
	self.toggle_button = $ToggleButton
	self.visits_label = $Visits
	toggle_button.text = "+"
	toggle_button.connect("pressed", _on_toggle_pressed)
	# set default values
	self.board = board.duplicate(true)
	self.children = []
	self.expanded_moves = []
	self.is_fully_expanded = false
	self.is_terminal = false
	self.get_possible_moves()
	self.move_index = move_index
	self.score = 0.0
	self.visits = 0.0
	if parent:
		self.layer = parent.layer + 1
		self.mcts_graph_edit = parent.mcts_graph_edit
		self.parent = parent
		#self.connect_to_parent()
		#self.visible = false # turn invisible in GraphEdit to prevent laggs (except the root node)

func get_possible_moves() -> void:
	for i in range(len(self.board)):
		if self.board[i] == "":
			self.possible_moves.append(i)

# recursiv durch die children gehen und togglen
func toggle_descendants(visible: bool):
	for index in range(self.children.size()):
		var child: MCTSTreeNode = children[index]
		if visible:
			self.mcts_graph_edit.add_child(children[index])
			# connect right side of self to left side of child
			self.mcts_graph_edit.connect_node(self.name, 0, child.name, 0)
			self.children_expanded = visible
			self.toggle_button.text = "-"
			if len(child.children) == 0:
				child.toggle_button.disabled = visible
				child.toggle_button.text = "Nothing to expand"
			else:
				child.toggle_button.disabled = not visible
				child.toggle_button.text = "+"
			if index == children.size() - 1:
				# align nodes after expanding completely
				print("expanding align called")
				self.mcts_graph_edit.align_nodes()
		else:
			self.mcts_graph_edit.remove_child(child)
			# disconnect right side of self from left side of child
			self.mcts_graph_edit.disconnect_node(self.name, 0, child.name, 0)
			self.children_expanded = visible
			child.toggle_button.disabled = visible
			child.toggle_button.text = "+"
			if child.children_expanded:
				child.children_expanded = visible
				child.toggle_descendants(visible)
			elif index == children.size() - 1:
				# align nodes after collapsing completely
				print("collapsed align called")
				self.mcts_graph_edit.align_nodes()

# position within the GraphEdit symmetrically
func position_self(amount_nodes: int, row: int, root_layer: int) -> void:
	# position graph node corresponding to its layer and its siblings amount
	var y_range: float = (amount_nodes * (self.size.y * 2)) - (self.size.y * 2)
	var upper_y: float = (y_range / 2) * -1
	var x: float = (self.layer - root_layer) * (self.size.x * 6)
	var y: float = upper_y + (row * (self.size.y * 2))
	self.position_offset = Vector2(x, y)

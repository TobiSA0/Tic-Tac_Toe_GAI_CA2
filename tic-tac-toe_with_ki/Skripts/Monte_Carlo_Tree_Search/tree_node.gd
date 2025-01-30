class_name TreeNode
extends GraphNode

const DEBUG: bool = false

@export var children_expanded: bool = false
@onready var board_grid: GridContainer
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
var children: Array[TreeNode]
var expanded_moves: Array[int]
var is_fully_expanded: bool
var is_terminal: bool
var layer: int:
	set(value):
		layer = value
		layer_label.text = "Layer: " + str(value)
var graph_edit: MctsGraphEdit
var move_index: int
var parent: TreeNode
var possible_moves: Array[int]
var score: float:
	set(value):
		score = value
		score_label.text = "Score: " + str(value)
var visits: float:
	set(value):
		visits = value
		visits_label.text = "Visits: " + str(value)

# runs when new TreeNode scene is instantiated
func _init() -> void:
	# add slots with index 0 for left side (input) and for right side (output)
	self.set_slot(0, true, 0, Color.WHITE, true, 0, Color.WHITE)

#
func add_values(board: Array[String], parent: TreeNode, move_index: int) -> void:
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
		self.graph_edit = parent.graph_edit
		self.parent = parent
		#self.connect_to_parent()
		#self.visible = false # turn invisible in GraphEdit to prevent laggs (except the root node)

func get_possible_moves() -> void:
	for i in range(len(self.board)):
		if self.board[i] == "":
			self.possible_moves.append(i)

# connect graph node to parent graph node
func connect_to_parent() -> void:
	if self.parent:
		if DEBUG:
			print("Connecting to parent...")
	else:
		if DEBUG:
			print("No parent to connect to...")

# position within the GraphEdit to make graph symmetrical
func position_self(amount_nodes: int, row: int, root_layer: int) -> void:
	# position graph node corresponding to its layer and its siblings amount
	var y_range: float = (amount_nodes * (self.size.y * 2)) - (self.size.y * 2)
	var upper_y: float = (y_range / 2) * -1
	var x: float = (self.layer - root_layer) * (self.size.x * 6)
	var y: float = upper_y + (row * (self.size.y * 2))
	#print("row: ", row)
	self.position_offset = Vector2(x, y)

# expand and collapse the tree node children in graph
func _on_toggle_pressed():
	#print("Toggle button pressed for", self.name)
	children_expanded = not children_expanded
	toggle_button.text = "-" if children_expanded else "+"
	toggle_descendants(children_expanded)

# recursiv durch die children gehen und togglen
func toggle_descendants(visible: bool):
	for child in self.children:
		child.visible = visible
		if visible:
			# connect right side of self to left side of child
			child.graph_edit.add_child(child)
			child.graph_edit.connect_node(self.name, 0, child.name, 0)
			if len(child.children) == 0:
				child.toggle_button.disabled = visible
				child.toggle_button.text = "Nothing to expand"
		else:
			# disconnect right side of self from left side of child
			self.graph_edit.disconnect_node(self.name, 0, child.name, 0)
			child.graph_edit.remove_child(child)
			child.toggle_button.disabled = visible
			child.toggle_button.text = "+"
			if child.children_expanded:
				child.children_expanded = false
				child.toggle_descendants(false)
			child.toggle_button.text = "+"
	self.graph_edit.align_nodes()

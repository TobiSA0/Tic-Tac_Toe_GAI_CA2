class_name TreeNode
extends GraphNode

@onready var board_label: GridContainer
@onready var layer_label: Label
@onready var score_label: Label
@onready var visits_label: Label

# attributes
var board: Array[String]:
	set(value):
		board = value
		for child in board_label.get_children():
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
var mcts_graph: MctsGraphEdit
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

# runs when GraphEdit adds this instance as child
func _ready() -> void:
	self.board_label = $Board
	self.layer_label = $Layer
	self.score_label = $Score
	self.visits_label = $Visits
	self.mcts_graph = self.get_parent()
	#print("TreeGraphNode _ready")

# constructor, runs when GraphEdit instantiates new TreeGraphNode scene
func add_values(board: Array[String], parent: TreeNode):
	# set default values
	self.board = board.duplicate(true)
	self.children = []
	self.expanded_moves = []
	self.is_fully_expanded = false
	self.is_terminal = false
	self.get_possible_moves()
	self.score = 0.0
	self.visits = 0.0
	if parent:
		self.layer = parent.layer + 1
		self.parent = parent
		self.connect_to_parent()
		self.move_index = self.get_move_index()

# 
func get_move_index() -> int:
	var index: int = -1
	if self.parent:
		for i in range(len(self.board)):
			if self.board[i] != self.parent.board[i]:
				return i
	return index

func get_possible_moves() -> void:
	for i in range(len(self.board)):
		if self.board[i] == "":
			self.possible_moves.append(i)

# connect graph node to parent graph node
func connect_to_parent() -> void:
	if self.parent:
		print("Connecting to parent...")
		# connect left side of parent to right side of self
		self.mcts_graph.connect_node(self.parent.name, 0, self.name, 0)
	else:
		print("No parent to connect to...")

# position within the GraphEdit to make graph symmetrical
func position_self(amount_nodes: int, row: int) -> void:
	# position graph node corresponding to its layer and its siblings amount
	var y_range: float = (amount_nodes * (self.size.y * 2)) - (self.size.y * 2)
	var upper_y: float = (y_range / 2) * -1
	var x: float = self.layer * (self.size.x * 6)
	var y: float = upper_y + (row * (self.size.y * 2))
	self.position_offset = Vector2(x, y)

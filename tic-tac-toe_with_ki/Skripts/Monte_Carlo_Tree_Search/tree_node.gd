class_name TreeNode
extends RefCounted

# attributes
var board: Array[String]
var children: Array[TreeNode]
var expanded_moves: Array[int]
var is_fully_expanded: bool
var is_terminal: bool
var layer: int
var parent: TreeNode
var possible_moves: Array[int]
var score: float
var slots: int
var graph_node: TreeGraphNode
var visits: float

# constructor
func _init(board: Array[String], parent: TreeNode, layer: int):
	self.board = board.duplicate(true)
	self.children = []
	self.expanded_moves = []
	self.is_fully_expanded = false
	self.is_terminal = false
	self.layer = layer
	self.parent = parent
	self.possible_moves = []
	self.score = 0.0
	self.graph_node = null
	self.visits = 0.0

func get_children() -> Array:
	return self.children

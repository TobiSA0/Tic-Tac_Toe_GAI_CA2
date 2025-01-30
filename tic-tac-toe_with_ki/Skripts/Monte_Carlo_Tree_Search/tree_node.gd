extends Node

# NOT USED YET
# tree node class definition
class TreeNode:
	var board: Array[Field]
	var children: Array[TreeNode]
	var is_fully_expanded: bool
	var is_terminal: bool
	var parent: TreeNode
	var score: float 
	var visits: float

	# constructor
	func _init(board: Array[Field], parent: TreeNode = null):
		self.board = board
		self.children = []
		self.is_fully_expanded = false
		self.is_terminal = false
		self.parent = parent
		self.score = 0.0
		self.visits = 0.0

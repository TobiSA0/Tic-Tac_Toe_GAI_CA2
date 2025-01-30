class_name MCTS
extends Controler

const DEBUG: bool = false
const ITERATIONS: int = 1000
const TREE_NODE = preload("res://Scenes/tree_node.tscn")

@onready var graph_edit: MctsGraphEdit = $"../../MCTSGraphWindow/MCTSGraph"
@onready var symbol: String = "O" if self.player_name == "Player1" else "X"
var root: TreeNode
var tree_nodes: Array[TreeNode]
var win_combinations = [
		[0, 1, 2], # 1st row
		[3, 4, 5], # 2nd row
		[6, 7, 8], # 3rd row
		[0, 3, 6], # 1st column
		[1, 4, 7], # 2nd column
		[2, 5, 8], # 3rd column
		[0, 4, 8], # 1st diagonal
		[2, 4, 6], # 2nd diagonal
	]

# 
func _ready() -> void:
	self.graph_edit.mcts = self

# play best move for current board state
func action():
	var best_node: TreeNode = self.search()
	# play best move
	print("best move: ", best_node.move_index)
	return playfield.get_list_of_fields()[best_node.move_index]

func add_node(board: Array[String], parent_node: TreeNode, move_index: int) -> TreeNode:
	var tree_node: TreeNode = TREE_NODE.instantiate()
	self.tree_nodes.append(tree_node)
	tree_node.add_values(board, parent_node, move_index)
	#tree_node.title = str(self.node_counter)
	return tree_node

# backpropagate the number of visits and score up to the root node
func backpropagate(node: TreeNode, score: float) -> void:
	# update nodes up to root node
	while node != null:
		# update visits
		node.visits += 1
		# update score
		node.score += score
		# set node to parent
		node = node.parent

func delete_irrelevant_nodes(node: TreeNode) -> void:
		if node and node != self.root:
			for child in node.children:
				if child != self.root:
					delete_irrelevant_nodes(child)
			self.tree_nodes.erase(node)
			node.free()

# expand a node
func expand(node: TreeNode) -> TreeNode:
	# generate outcome boards for each possible move
	for move_index in node.possible_moves:
		# make sure that move has not been simulated already
		if not node.expanded_moves.has(move_index):
			# add expanded move to expanded_moves
			node.expanded_moves.append(move_index)
			# remove expanded move from possible_moves
			node.possible_moves.erase(move_index)
			# create new board
			var new_board: Array[String] = simulate_move(node.board, move_index, self.get_symbol(node.board))
			var tree_node: TreeNode
			# create a new child
			tree_node = self.add_node(new_board, node, move_index)
			# add child node to parent node
			node.children.append(tree_node)
			# check if child node is terminal
			if is_terminal(tree_node.board):
				tree_node.is_terminal = true
			# check if parent node is fully expanded
			if len(node.possible_moves) == 0:
				node.is_fully_expanded = true
			# return child node
			return tree_node
	# debug
	print("Should not get here! No child node returned when expanding.")
	return null

# select the best node based on UCB1 formula
func get_best_move(node: TreeNode, exploration_constant: float) -> TreeNode:
	# define best score and best moves
	var best_score: float = -INF
	var best_moves: Array[TreeNode] = []
	
	# loop over child nodes
	for child_node in node.children:
		# get move score using UCT formula
		var move_score: float = (child_node.score / child_node.visits) + exploration_constant * sqrt((log(node.visits) / child_node.visits))
		
		# debug
		#if exploration_constant == 0:
			#print("amount of children: ", len(node.children))
			#print("child score: ", child_node.score)
			#print("child visits: ", child_node.visits)
			#print("move_score for child with move index ", child_node.move_index, ": ", move_score)
		
		# better move is found
		if move_score > best_score:
			best_score = move_score
			best_moves = [child_node]
		
		# found as good move as already set
		elif move_score == best_score:
			best_moves.append(child_node)
	
	# return one of the best moves randomly
	var random_index = randi() % best_moves.size()
	if exploration_constant == 0:
		print("BREAK")
	return best_moves[random_index]

func get_current_board() -> Array[String]:
	# create current board state as string array
	var current_board: Array[String] = []
	for field in self.playfield.get_list_of_fields():
		current_board.append(field.get_content())
	return current_board

#func get_current_board() -> Array[Field]:
	#return self.board

# get a score for a board simulation
func get_score(board: Array[String]) -> int:
	# check for each win combination if board state matches it with one symbol
	for combination in self.win_combinations:
		var board_values: Array[String] = []
		for index in combination:
			board_values.append(board[index])
		# check if X or O matches all 3 spots in win combination
		if board_values[0] != "" and board_values[0] == board_values[1] and board_values[0] == board_values[2]:
			# win or lose
			return 1 if board_values[0] == self.symbol else -1
	# draw
	return 0

func get_symbol(board: Array[String]) -> String:
	var counter: int
	for field in board:
		if field != "":
			counter +=1
	return "O" if counter % 2 == 0 else "X"

# check if there is a terminal state in a board simulation
func is_terminal(board: Array[String]) -> bool:
	# check if there is a winner
	if is_won(board):
		return true
	# check if there is a draw
	for field in board:
		# check if field is empty
		if field == "":
			# if one field is empty, then there is no draw
			return false
	# if no field is empty and there is no win, then there is a draw
	return true

func is_won(board: Array[String]) -> bool:
	# check for each win combination if board state matches it with one symbol
	for combination in self.win_combinations:
		var board_values: Array[String] = []
		for index in combination:
			board_values.append(board[index])
		# check if X or  matches all 3 spots in win combination
		if board_values[0] != "" and board_values[0] == board_values[1] and board_values[0] == board_values[2]:
			# win
			return true
	# no win
	return false

# make random, legal move on a board simulation for current player
func random_move(board_simulation: Array[String]) -> Array[String]:
	# define possible moves
	var possible_moves = []
	# loop through board
	for index in range(len(board_simulation)):
		# write down empty field indexes as possible moves
		if board_simulation[index] == "":
			# add move to possible_moves
			possible_moves.append(index)
	# if moves possible, do a random move
	if len(possible_moves) > 0:
		var random_index = randi() % len(possible_moves)
		#print("random_index = ", random_index)
		board_simulation[possible_moves[random_index]] = get_symbol(board_simulation)
	return board_simulation

# simulate the game with random moves until end of game is reached
func rollout(board: Array[String]) -> int:
	#var current_player: String = self.player_name
	var board_simulation: Array[String] = board.duplicate(true)
	# make random moves for both sides until game is terminal
	while not is_terminal(board_simulation):
		# make a random move for current player
		board_simulation = random_move(board_simulation)
	# return the score corresponding to game result
	return get_score(board_simulation)

# search for the turn with the best win probability
func search() -> TreeNode:
	# create new root node on first turn
	if self.root == null:
		self.root = self.add_node(self.get_current_board(), null, -1)
		self.root.graph_edit = self.graph_edit
		self.graph_edit.add_child(self.root)
	# overwrite root node on following turns
	else:
		var old_root = self.root
		for tree_node in self.tree_nodes:
			if self.get_current_board() == tree_node.board:
				self.root = tree_node
				# delete all irrelevant nodes
				self.delete_irrelevant_nodes(old_root)
				self.root.position_offset = Vector2(0, 0)
				break
	# run through iterations
	for iteration in range(ITERATIONS - 1):
		# selection
		var tree_node = self.select(self.root)
		# simulation
		var score = self.rollout(tree_node.board)
		# backpropagation
		self.backpropagate(tree_node, score)
	# pick the best child for the root (best move for current board state)
	var index: int
	var best_node: TreeNode = self.get_best_move(self.root, 0)
	index = best_node.move_index
	if index < 0 or index > 8:
		# shouldn't get here
		push_error("Illegale move was calculated")
	return best_node

# select most promising child node
func select(node: TreeNode) -> TreeNode:
	# debug
	if node != self.root:
		print("BREAK")
	# make sure we're dealing with non-terminal nodes
	while not node.is_terminal:
		# case: node is fully expanded
		if node.is_fully_expanded:
			#print("For iteration ", self.current_iteration, " algorithm is getting best move!")
			node = self.get_best_move(node, 5)
		# case: node is not fully expanded
		else:
			# otherwise expand the node
			#print("For iteration ", self.current_iteration, " algorithm is expanding!")
			return self.expand(node)
	return node

# simulate a move on a given board state
func simulate_move(board: Array[String], move: int, symbol: String) -> Array[String]:
	var copy_board: Array[String] = board.duplicate(true)
	copy_board[move] = symbol
	return copy_board

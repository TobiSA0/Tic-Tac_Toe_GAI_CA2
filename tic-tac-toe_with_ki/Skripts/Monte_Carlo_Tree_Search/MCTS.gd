extends Controler
class_name MCTS

const DEBUG: bool = true
const ITERATIONS: int = 300
const TREE_NODE = preload("res://Scenes/tree_node.tscn")

@onready var enemy_name: String = "Player1" if player_name == "Player2" else "Player2"
@onready var mcts_graph_edit: MctsGraphEdit = $"../../MCTSGraphWindow/MCTSGraph"
#var root: TreeNode

# play best move for current board state
func action():
	# clear nodes from graph from previous turn
	mcts_graph_edit.clear_nodes()
	# copy current board state as string array
	var initial_board: Array[String] = []
	for field in playfield.get_list_of_fields():
		initial_board.append(field.get_content())
	# search for move with best win probability
	var copy_initial_board = initial_board.duplicate(true)
	var best_move_index: int = self.search(copy_initial_board)
	# align all nodes symmetrically in graph edit
	mcts_graph_edit.align_nodes()
	# debug
	if DEBUG:
		var index: int = 0
		for child in mcts_graph_edit.children:
			var counter: int = 0
			var c_board = child.board
			for i in range(len(mcts_graph_edit.children)):
				if i != index:
					if c_board == mcts_graph_edit.children[i].board:
						print("duplicate for child ", index + 1, " found at index ",  i + 1)
						print("c_board:         ", c_board, "\nduplicate board: " , mcts_graph_edit.children[i].board)
			index += 1
	# play move
	return playfield.get_list_of_fields()[best_move_index]

# MCTS algorithm: create various TreeNodes with different play turns and search for the turn with the best win probability 
func search(initial_board: Array[String]) -> int:
	var tree_node: TreeNode = TREE_NODE.instantiate()
	mcts_graph_edit.add_node(tree_node)
	tree_node.add_values(initial_board, null)
	# walk through x iterations
	for iteration in range(ITERATIONS):
		# select a node (selection)
		var node = self.select(tree_node)
		# score for current node (simulation)
		var score = self.rollout(node.board)
		# backpropagate the number of visits and score up to the root node
		self.backpropagate(node, score)
	# pick the best move in the current board
	var index: int = -1
	var best_node: TreeNode = self.get_best_move(tree_node, 0)
	index = best_node.move_index
	if index == -1:
		# shouldn't get here
		push_error("Ein fehlerhafter Zug wurde berechnet!")
	return index

# select most promising node
func select(node: TreeNode) -> TreeNode:
	# make sure we're dealing with non-terminal nodes
	while not node.is_terminal:
		# case: node is fully expanded
		if node.is_fully_expanded:
			node = self.get_best_move(node, 2)
		# case: node is not fully expanded
		else:
			# otherwise expand the node
			return self.expand(node)
	return node

# expand a node
func expand(node: TreeNode) -> TreeNode:
	# check whose turn it is depending on amount of possible moves and therefore moves made/simulated
	var symbol = "X" if player_name == "Player2" else "O"
	# generate outcome boards for each possible move
	for move_index in node.possible_moves:
		# make sure that move has not been simulated already
		if not node.expanded_moves.has(move_index):
			# add expanded move to expanded_moves
			node.expanded_moves.append(move_index)
			# remove expanded move from possible_moves
			node.possible_moves.erase(move_index)
			# initial board copy
			var copy_board = node.board.duplicate(true)
			# create new board
			var new_board: Array[String] = simulate_move(copy_board, move_index, symbol)
			var tree_node: TreeNode
			
			
			#----version 1----
			# check if there is already a tree node with the exact same board layout (from other expanding)
			#for child in mcts_graph_edit.children:
				#if child.board == copy_board:
					#print("duplicate board state found")
					#tree_node = child
					#break
				#else:
					## create a new child
					#tree_node = TREE_NODE.instantiate()
					#mcts_graph_edit.add_node(tree_node)
					#tree_node.add_values(new_board, node)
					## add child node to parent node
					#node.children.append(tree_node)
					## check if child node is terminal
					#if check_simulation_terminal(tree_node.board):
						#tree_node.is_terminal = true
			#----version 1----
			
			#----version 2----
			# create a new child
			tree_node = TREE_NODE.instantiate()
			mcts_graph_edit.add_node(tree_node)
			tree_node.add_values(new_board, node)
			# add child node to parent node
			node.children.append(tree_node)
			node.add_child_node(tree_node)
			# check if child node is terminal
			if check_simulation_terminal(tree_node.board):
				tree_node.is_terminal = true
			#----version 2----
			
			
			# check if parent node is fully expanded
			if len(node.possible_moves) == 0:
				node.is_fully_expanded = true
			# return child node
			return tree_node
	# debug
	print("Should not get here! No child node returned when expanding.")
	return null

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

# simulate the game with random moves until end of game is reached
func rollout(board: Array[String]) -> int:
	#var current_player: String = self.player_name
	var board_simulation: Array[String] = board.duplicate(true)
	# make random moves for both sides until game is terminal
	while not check_simulation_terminal(board_simulation):
		# make a random move for current player
		board_simulation = random_move(board_simulation)
	# return the score corresponding to game result
	var winner_name = check_simulation_winner(board_simulation)
	if winner_name == player_name: # player wins simulation
		return 1
	elif winner_name == enemy_name: # enemy wins simulation
		return -1
	else: # draw simulation
		return 0

# make random, legal move on a board simulation for current player
func random_move(board_simulation: Array[String]) -> Array[String]:
	# define possible moves
	var possible_moves = []
	# loop through board
	for index in range(len(board_simulation)):
		# make sure field is empty
		if board_simulation[index] == "":
			# add move to possible_moves
			possible_moves.append(index)
	# if moves possible, do a random move
	if len(possible_moves) > 0:
		var symbol = "X" if (len(possible_moves) % 2 == 0) else "O"
		var random_index = randi() % len(possible_moves)
		#print("random_index = ", random_index)
		board_simulation[possible_moves[random_index]] = symbol
	return board_simulation

# select the best node based on UCB1 formula
func get_best_move(node: TreeNode, exploration_constant: int) -> TreeNode:
	# define best score and best moves
	var best_score: float = -INF
	var best_moves: Array[TreeNode] = []
	
	# loop over child nodes
	for child_node in node.children:
		# define current player
		var current_player = 1 if player_name == "Player1" else -1
		# get move score using UCT formula
		var move_score: float = current_player * (child_node.score / child_node.visits) + exploration_constant * sqrt(log(node.visits) / child_node.visits)
		
		# better move is found
		if move_score > best_score:
			best_score = move_score
			best_moves = [child_node]
		
		# found as good move as already set
		elif move_score == best_score:
			best_moves.append(child_node)
	
	# return one of the best moves randomly
	var random_index = randi() % best_moves.size()
	return best_moves[random_index]

# simulate a move on a given board state
func simulate_move(board: Array[String], move: int, symbol: String) -> Array[String]:
	board[move] = symbol
	return board

# check if there is a terminal state in a board simulation
func check_simulation_terminal(simulation_board) -> bool:
	# check if there is a winner
	var winner: String = check_simulation_winner(simulation_board)
	if winner != "No Winner":
		return true
	# check if there is a draw
	for field in simulation_board:
		# check if field is empty
		if field == "":
			# if one field is empty, then there is no draw
			return false
	# if no field is empty, then there is a draw
	return true

# check if there is a winner in a board simulation
func check_simulation_winner(simulation_board) -> String:
	var win_combinations = [[0, 1, 2], [3, 4, 5], [6, 7, 8], [2, 4, 6], [0, 4, 8], [0, 3, 6], [1, 4, 7], [2, 5, 8]]
	for combination in win_combinations:
		var values: Array[String] = []
		for pos in combination:
			values.append(simulation_board[pos])
		if values[0] != "" and values[0] == values[1] and values[0] == values[2]:
			# when Player1 is
			return "Player1" if values[0] == "O" else "Player2"
	# no winner
	return "No Winner"

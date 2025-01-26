extends Controler
class_name MCTS

const ITERATIONS: int = 100
const TIME_TO_WAIT: int = 1
const TREE_GRAPH_NODE = preload("res://Scenes/tree_graph_node.tscn")

@onready var enemy_name: String = "Player1" if player_name == "Player2" else "Player2"
var root: TreeNode
var timer_is_done: bool = false
var timer_active: bool = false
var timer: Timer
@onready var mcts_graph: MctsGraph = $"../../MCTSGraphWindow/MCTSGraph"

func _ready() -> void:
	timer = Timer.new()
	timer.connect("timeout",Callable(self,"_on_timer_timeout"))
	get_parent().add_child(timer)

func _on_timer_timeout():
	print("hi")
	timer_is_done = true
	
func start_timer():
	timer.wait_time = TIME_TO_WAIT
	timer.start()

# determine which move is the best
func action():
	var initial_board: Array[String] = []
	for field in playfield.get_list_of_fields():
		initial_board.append(field.get_content())

	var best_move: int = self.search(initial_board)
	mcts_graph.align_nodes()
	return playfield.get_list_of_fields()[best_move]

# MCTS algorithm: create various TreeNodes with different play turns and search for the turn with the best win probability 
func search(initial_board: Array[String]) -> int:
	# create root node based on current board state
	var board_copy = initial_board.duplicate(true)
	self.root = TreeNode.new(board_copy, null, 0)
	mcts_graph.add_graph_node(self.root)
	# walk through x iterations
	for iteration in range(ITERATIONS):
		# select a node (selection)
		var node = self.select(self.root)
		
		# score for current node (simulation)
		var score = self.rollout(node.board)
		
		# backpropagate the number of visits and score up to the root node
		self.backpropagate(node, score)
	
	# pick the best move in the current board
	var best_node: TreeNode = self.get_best_move(self.root, 0)
	var best_board: Array[String] = best_node.board
	var index: int = -1
	for i in range(len(best_board)):
		if best_board[i] != board_copy[i]:
			index = i
			break
	if index == -1:
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
			return self.expand(node) #return self.expand(node)
	#print("BREAK")
	return node

# expand a node
func expand(node: TreeNode) -> TreeNode:
	# legal boards after one move for the given node
	var possible_boards = []
	var possible_moves: Array[int] = _get_possible_moves(node.board) #node.possible_moves
	# check which turn it is depending on amount of possible moves and therefore moves made/simulated
	var symbol = "X" if (len(possible_moves) % 2 == 0) else "O"
	# generate outcome boards for each possible move
	for move in possible_moves:
		#if len(possible_moves) < 3:
			#print("BREAK")
		# make sure that child is not already created and appended
		if not node.expanded_moves.has(move):
			# initial board copy
			var current_board = node.board.duplicate(true)
			# create new board
			#print("1:", current_board)
			var new_board: Array[String] = simulate_move(current_board, move, symbol).duplicate(true)
			#print("2: ", current_board)
			#print("3: ", new_board)
			# create a new child
			var a = node.layer
			var child_node = TreeNode.new(new_board, node, node.layer + 1)
			mcts_graph.add_graph_node(child_node)
			# add child node to parent node
			node.children.append(child_node)
			# check if child node is terminal
			if len(possible_moves) == 1:
				child_node.is_terminal = true
			if len(possible_moves) == len(node.children):
				node.is_fully_expanded = true
			# add move to expanded_moves
			node.expanded_moves.append(move)
			# remove move from possible_moves
			#node.possible_moves.remove_at(0)
			# return child node
			return child_node
	# after expaning every move, set parent to fully expanded
	#node.is_fully_expanded = true
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
		#board_simulation = generate_board_randomly(board_simulation)
		board_simulation = random_move(board_simulation)
		# swap current player for possible next turn
		#current_player = self.player_name if current_player != self.player_name else self.enemy
	# return the score corresponding to game result
	var winner_name = check_simulation_winner(board_simulation)
	if winner_name == player_name: # player wins simulation
		return 1
	elif winner_name == enemy_name: # enemy wins simulation
		return -1
	else: # draw simulation
		return 0

# make random, legal move on a board simulation for current player
func generate_board_randomly(board_simulation: Array[String]) -> Array[String]:
	var current_player: String = self.player_name
	# define possible moves
	var possible_moves = []
	# loop through board
	for index in range(len(board_simulation)):
		# make sure field is empty
		if board_simulation[index] == "":
			# add move to possible_moves
			possible_moves.append(index)
	# if moves possible
	while len(possible_moves) > 0:
		var symbol = "X" if (len(possible_moves) % 2 == 0) else "O"
		# do random move for current player
		var random_index = randi() % len(possible_moves)
		#print("random_index = ", random_index)
		#board_simulation[random_index + 1] = "X" if current_player == "Player2" else "O"
		board_simulation[random_index + 1] = symbol
		possible_moves.remove_at(random_index)
		# swap current player for possible next turn
		current_player = self.player_name if current_player != self.player_name else self.enemy
	return board_simulation

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
		var move_score = 1 * child_node.score / child_node.visits + exploration_constant * sqrt(log(node.visits) / child_node.visits)
		
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

# get all possible moves for a board
func _get_possible_moves(board: Array[String]) -> Array[int]:
	var possible_moves: Array[int] = []
	for i in range(board.size()):
		if board[i] == "":
			possible_moves.append(i)
	return possible_moves

# simulate a move on a board and return the new board
func simulate_move(board: Array[String], move: int, symbol: String) -> Array[String]:
	#var copy = board.duplicate(true)
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

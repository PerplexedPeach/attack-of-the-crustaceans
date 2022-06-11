tool
class_name Cursor
extends Node2D

# We'll use signals to keep the cursor decoupled from other nodes.
# When the player moves the cursor or wants to interact with a cell, we emit a signal and let
# another node handle the interaction.

# Emitted when clicking on the currently hovered cell or when pressing "ui_accept".
signal accept_pressed(cell)
# Emitted when the cursor moved to a new cell.
signal moved(new_cell)

# Grid resource, giving the node access to the grid size, and more.
export (NodePath) var grid_path
onready var grid = get_node(grid_path)
# Time before the cursor can move again in seconds.
# You can see how we use it in the unhandled input function below.
export var ui_cooldown := 0.1

# Coordinates of the current cell the cursor is hovering.
var cell := Vector2.ZERO setget set_cell

onready var _timer: Timer = $Timer


# When the cursor enters the scene tree, we snap its position to the centre of the cell and we
# initialise the timer with our ui_cooldown variable.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	_timer.wait_time = ui_cooldown
	position = grid.calculate_map_position(cell)


func _unhandled_input(event: InputEvent) -> void:
	# If the user moves the mouse, we capture that input and update the node's cell in priority.
	if event is InputEventMouseMotion:
		var local_pos = get_viewport().canvas_transform.affine_inverse().xform(event.position)
		# keep cursor inside the grid when half cell size out
		local_pos += Vector2.ONE * grid.cell_size / 2

		self.cell = grid.calculate_grid_coordinates(local_pos)
#		self.cell = grid.calculate_grid_coordinates(event.position)
	# If we are already hovering the cell and click on it, or we press the enter key, the player
	# wants to interact with that cell.
	elif event.is_action_pressed("click") or event.is_action_pressed("ui_accept"):
		#  In that case, we emit a signal to let another node handle that input. The game board will
		#  have the responsibility of looking at the cell's content.
		emit_signal("accept_pressed", cell)
		get_tree().set_input_as_handled()

	# The code below is for the cursor's movement.
	# The following lines make some preliminary checks to see whether the cursor should move or not
	# if the user presses an arrow key.
	var should_move := event.is_pressed()
	# If the player is pressing the key in this frame, we allow the cursor to move. If they keep the
	# keypress down, we only want to move after the cooldown timer stops.
	if event.is_echo():
		should_move = should_move and _timer.is_stopped()

	# And if the cursor shouldn't move, we prevent it from doing so.
	if not should_move:
		return

	# Here, we update the cursor's current cell based on the input direction. See the set_cell()
	# function below to see what changes that triggers.
	if event.is_action("ui_right"):
		self.cell += Vector2.RIGHT
	elif event.is_action("ui_up"):
		self.cell += Vector2.UP
	elif event.is_action("ui_left"):
		self.cell += Vector2.LEFT
	elif event.is_action("ui_down"):
		self.cell += Vector2.DOWN


# We use the draw callback to a rectangular outline the size of a grid cell, with a width of two
# pixels.
func _draw() -> void:
	# Rect2 is built from the position of the rectangle's top-left corner and its size. To draw the
	# square around the cell, the start position needs to be `-grid.cell_size / 2`.
	draw_rect(Rect2(-grid.cell_size / 2, grid.cell_size), Color.aliceblue, false, 2.0)


# This function controls the cursor's current position.
func set_cell(value: Vector2) -> void:
	var new_cell: Vector2 = value
	if new_cell.is_equal_approx(cell):
		return

	cell = new_cell
	# If we move to a new cell, we update the cursor's position, emit a signal, and start the
	# cooldown timer that will limit the rate at which the cursor moves when we keep the direction
	# key down.
	position = grid.calculate_map_position(cell)
	print("should be drawing at cell %s position %s" % [cell, position])
	emit_signal("moved", cell)
	_timer.start()

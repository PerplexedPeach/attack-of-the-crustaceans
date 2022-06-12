# Represents and manages the game board. Stores references to entities that are in each cell and
# tells whether cells are occupied or not.
# Units can only move around the grid one at a time.
class_name GameBoard
extends Node2D

# This constant represents the directions in which a unit can move on the board. We will reference
# the constant later in the script.
const DIRECTIONS = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]


export (NodePath) var grid_path
onready var grid : Grid = get_node(grid_path)
onready var _unit_overlay: Overlay = $Overlay

# We use a dictionary to keep track of the units that are on the board. Each key-value pair in the
# dictionary represents a unit. The key is the position in grid coordinates, while the value is a
# reference to the unit.
# Mapping of coordinates of a cell to a reference to the unit it contains.
var _units := {}

var _active_unit: Unit
# This is an array of all the cells the `_active_unit` can move to. We will populate the array when
# selecting a unit and use it in the `_move_active_unit()` function below.
var _actionable_cells := {}

onready var _unit_path: UnitPath = $UnitPath


func _ready() -> void:
	_reinitialize()
	# This call is temporary, remove it after testing and seeing the overlay works as expected.
#	_unit_overlay.draw(get_actionable_cells($Unit))

func cell_to_action(cell: Vector2):
	var unit = _units.get(cell)
	# TODO add SQUASH action if that cell belongs to an enemy
	if unit != null:
		pass
	return Grid.TileAction.WALK

func _reinitialize() -> void:
	_units.clear()

	for child in get_children():
		# We can use the "as" keyword to cast the child to a given type. If the child is not of type
		# Unit, the variable will be null.
		var unit := child as Unit
		if not unit:
			continue
		_units[unit.cell] = unit

# Returns an array of cells a given walker can navigate
func get_actionable_cells(walker: Unit) -> Dictionary:
	return _flood_fill(walker.cell, walker.move_range)

# Returns an array with all the coordinates of walkable cells based on the `max_distance`.
func _flood_fill(cell: Vector2, max_distance: int) -> Dictionary:
	var visited = {}
	# DFS
	var stack = [cell]
	while not stack.empty():
		var current = stack.pop_back()

		if visited.get(current) != null:
			continue

		# limit by manhattan distance
		var difference: Vector2 = (current - cell).abs()
		var distance := int(difference.x + difference.y)
		if distance > max_distance:
			continue

		visited[current] = cell_to_action(current)
		
		for direction in DIRECTIONS:
			var coordinates: Vector2 = current + direction
			if not grid.is_walkable(coordinates):
				continue
			if visited.get(coordinates) != null:
				continue

			# TODO don't stack that for more filling because we cannot move past them
			stack.append(coordinates)
	return visited

# Selects the unit in the `cell` if there's one there.
# Sets it as the `_active_unit` and draws its walkable cells and interactive move path.
func _select_unit(cell: Vector2) -> void:
	if not _units.has(cell):
		return

	# When selecting a unit, we turn on the overlay and path drawing. We could use signals on the
	# unit itself to do so, but that would split the logic between several files without a big
	# maintenance benefit and we'd need to pass extra data to the unit.
	_active_unit = _units[cell]
	_active_unit.is_selected = true
	_actionable_cells = get_actionable_cells(_active_unit)
	_unit_overlay.draw(_actionable_cells)
	_unit_path.initialize(_actionable_cells.keys())


# Deselects the active unit, clearing the cells overlay and interactive path drawing.
# We need it for the `_move_active_unit()` function below, and we'll use it again in a moment.
func _deselect_active_unit() -> void:
	_active_unit.is_selected = false
	_unit_overlay.clear()
	_unit_path.stop()


# Clears the reference to the _active_unit and the corresponding walkable cells.
# We need it for the `_move_active_unit()` function below.
func _clear_active_unit() -> void:
	_active_unit = null
	_actionable_cells.clear()


# Updates the _units dictionary with the target position for the unit and asks the _active_unit to
# walk to it.
func _move_active_unit(new_cell: Vector2) -> void:
	if not new_cell in _actionable_cells:
		print("%s not in actionable cells" % new_cell)
		return

	# When moving a unit, we need to update our `_units` dictionary. We instantly save it in the
	# target cell even if the unit itself will take time to walk there.
	# While it's walking, the player won't be able to issue new commands.
	_units.erase(_active_unit.cell)
	_units[new_cell] = _active_unit
	# We also deselect it, clearing up the overlay and path.
	_deselect_active_unit()
	# We then ask the unit to walk along the path stored in the UnitPath instance and wait until it
	# finished.
	print("walking to %s" % new_cell)
	_active_unit.walk_along(_unit_path.current_path)
	yield(_active_unit, "walk_finished")
	print("walk finished to %s" % new_cell)
	# Finally, we clear the `_active_unit`, which also clears the `_walkable_cells` array.
	_clear_active_unit()


func _on_Cursor_moved(new_cell: Vector2) -> void:
	# When the cursor moves, and we already have an active unit selected, we want to update the
	# interactive path drawing.
	if _active_unit and _active_unit.is_selected:
		_unit_path.draw(_active_unit.cell, new_cell)


# Selects or moves a unit based on where the cursor is.
func _on_Cursor_accept_pressed(cell: Vector2) -> void:
	# The cursor's "accept_pressed" means that the player wants to interact with a cell. Depending
	# on the board's current state, this interaction means either that we want to select a unit all
	# that we want to give it a move order.
	if not _active_unit:
		print("select %s" % cell)
		_select_unit(cell)
	elif _active_unit.is_selected:
		print("move to %s" % cell)
		_move_active_unit(cell)
	else:
		print("shouldn't happen click state at %s" % cell)


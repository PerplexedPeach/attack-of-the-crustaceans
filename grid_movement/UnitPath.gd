class_name UnitPath
extends TileMap

export (NodePath) var grid_path
onready var grid = get_node(grid_path)

var _pathfinder: PathFinder
var current_path := PoolVector2Array()

	
# Creates a new PathFinder that uses the AStar algorithm we use to find a path between two cells 
# among the `walkable_cells`.
# We'll call this function every time the player selects a unit.
func initialize(walkable_cells: Array) -> void:
	_pathfinder = PathFinder.new(grid, walkable_cells)


# Finds and draws the path between `cell_start` and `cell_end`.
func draw(cell_start: Vector2, cell_end: Vector2) -> void:
	# We first clear any tiles on the tilemap, then let the Astar2D (PathFinder) find the
	# path for us.
	clear()
	current_path = _pathfinder.calculate_point_path(cell_start, cell_end)
	# And we draw a tile for every cell in the path.
	for cell in current_path:
		set_cellv(cell, 0)
	# The function below updates the auto-tiling. Without it, you wouldn't get the nice path with curves
	# and the arrows on either end.
	update_bitmask_region()


# Stops drawing, clearing the drawn path and the `_pathfinder`.
func stop() -> void:
	_pathfinder = null
	clear()

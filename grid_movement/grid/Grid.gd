extends TileMap
class_name Grid

# mapping coordinates of a cell to enemies
var enemies = {}
const DIRECTIONS = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]
enum TileAction {WALK, SQUASH}

func request_move(pawn, direction):
	# TODO add movement onto an enemy for destroying them
	var cell_start = calculate_grid_coordinates(pawn.position)
	var cell_target = cell_start + direction
	if is_walkable(cell_target):
		return calculate_map_position(cell_target)
		
func calculate_grid_coordinates(map_position: Vector2) -> Vector2:
	return world_to_map(map_position)
	
func calculate_map_position(grid_position: Vector2) -> Vector2:
	return map_to_world(grid_position) + cell_size / 2
	
func is_walkable(cell_target):
	var cell_tile_id = get_cellv(cell_target)
	match cell_tile_id:
		-1, 0:
			return true
	return false
	
# Returns an array of cells a given walker can navigate
func get_walkable_cells(walker: Walker) -> Array:
	return _flood_fill(walker.cell, walker.movement_range)

# Returns an array with all the coordinates of walkable cells based on the `max_distance`.
func _flood_fill(cell: Vector2, max_distance: int) -> Array:
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

		# TODO add SQUASH action if that cell belongs to an enemy
		# but don't stack that for more filling because we cannot move past them
		visited[current] = TileAction.WALK
		
		for direction in DIRECTIONS:
			var coordinates: Vector2 = current + direction
			if not is_walkable(coordinates):
				continue
			if visited.get(coordinates) != null:
				continue

			# This is where we extend the stack.
			stack.append(coordinates)
	return visited

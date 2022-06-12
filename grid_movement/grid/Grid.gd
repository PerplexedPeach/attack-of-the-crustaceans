extends TileMap
class_name Grid

enum TileAction {WALK, SQUASH}

func request_move(pawn, direction):
	# TODO add movement onto an enemy for destroying them
	var cell_start = calculate_grid_coordinates(pawn.position)
	var cell_target = cell_start + direction
	if is_walkable(cell_target):
		return calculate_map_position(cell_target)
		
func event_position_to_viewport(position: Vector2, apply_half_offset=true) -> Vector2:
	var pos = get_viewport().canvas_transform.affine_inverse().xform(position)
	if apply_half_offset:
		pos += Vector2.ONE * cell_size / 2
	return pos
	
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

# Given Vector2 coordinates, calculates and returns the corresponding integer index. You can use
# this function to convert 2D coordinates to a 1D array's indices.
func as_index(cell: Vector2) -> int:
	var offset = get_used_rect()
	return int(cell.x - offset.position.x + offset.size.x * (cell.y - offset.position.y))

extends TileMap


func request_move(pawn, direction):
	var cell_start = world_to_map(pawn.position)
	var cell_target = cell_start + direction

	var cell_tile_id = get_cellv(cell_target)
	match cell_tile_id:
		-1, 0:
			return map_to_world(cell_target) + cell_size / 2

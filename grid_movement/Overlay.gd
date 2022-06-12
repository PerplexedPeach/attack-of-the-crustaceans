extends TileMap
class_name Overlay

export var movement_tile = 1
export var squash_tile = 2

func draw(cells_map):
	clear()
	for cell in cells_map:
#		print("drawing cell %s" % cell)
		match cells_map[cell]:
			Grid.TileAction.WALK:
				set_cellv(cell, movement_tile)
			Grid.TileAction.SQUASH:
				set_cellv(cell, squash_tile)
			_:
				assert(false, "unrecognized cellmap %s for cell %s" % [cells_map[cell], cell])

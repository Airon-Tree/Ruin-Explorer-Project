extends TileMapLayer
class_name WallLayer


## Convert a world position to a tile cell on this wall layer.
func world_to_cell(world_pos: Vector2) -> Vector2i:
	# Convert world space to local space of this TileMapLayer
	var local_pos: Vector2 = to_local(world_pos)
	# Convert local position to tile coordinates
	return local_to_map(local_pos)


## Check if a given tile cell is a wall (uses "is_wall" custom data).
func is_wall_cell(cell: Vector2i) -> bool:
	var tile_data: TileData = get_cell_tile_data(cell)
	if tile_data == null:
		return false
	return tile_data.get_custom_data("is_wall") == true


## Check if there is a wall at the given world position.
func is_wall_at_world_pos(world_pos: Vector2) -> bool:
	var cell: Vector2i = world_to_cell(world_pos)
	return is_wall_cell(cell)


## Check if the line between two world positions is clear of walls.
## Returns true if no wall tiles are found along the line.
func is_line_of_sight_clear(start_world: Vector2, end_world: Vector2) -> bool:
	# Convert world positions to tile cells
	var start_cell: Vector2i = world_to_cell(start_world)
	var end_cell: Vector2i = world_to_cell(end_world)

	# Bresenham line algorithm over tile coordinates
	var dx: int = abs(end_cell.x - start_cell.x)
	var dy: int = abs(end_cell.y - start_cell.y)
	var sx: int = 1 if start_cell.x < end_cell.x else -1
	var sy: int = 1 if start_cell.y < end_cell.y else -1
	var err: int = dx - dy

	var current: Vector2i = start_cell

	while true:
		# If current tile is a wall, LOS is blocked
		if is_wall_cell(current):
			return false

		# Reached the end cell → done
		if current == end_cell:
			break

		var e2: int = 2 * err
		if e2 > -dy:
			err -= dy
			current.x += sx
		if e2 < dx:
			err += dx
			current.y += sy

	# No wall tiles found along the line
	return true

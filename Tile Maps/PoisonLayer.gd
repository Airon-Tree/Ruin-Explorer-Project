extends TileMapLayer
class_name PoisonLayer

## Get damage per second from a tile (0 if no poison)
func get_dps_at_world_pos(world_pos: Vector2) -> float:
	# Convert world position to tilemap local coordinates
	var local_pos: Vector2 = to_local(world_pos)
	
	# Convert to tile coordinates
	var tile_coords: Vector2i = local_to_map(local_pos)

	# Fetch tile data
	var tile_data: TileData = get_cell_tile_data(tile_coords)
	if tile_data == null:
		return 0.0

	# Check if tile is poison
	var is_poison: bool = tile_data.get_custom_data("is_poison")
	if not is_poison:
		return 0.0

	# Fetch damage value (float)
	var dps: float = tile_data.get_custom_data("damage_per_second")
	return dps


## Check if the position is poison
func is_poison_at_world_pos(world_pos: Vector2) -> bool:
	# Convert world position to tilemap local
	var local_pos: Vector2 = to_local(world_pos)

	# Convert to tile coordinates
	var tile_coords: Vector2i = local_to_map(local_pos)

	# Fetch tile data
	var tile_data: TileData = get_cell_tile_data(tile_coords)
	if tile_data == null:
		return false

	# Return boolean custom data
	return tile_data.get_custom_data("is_poison")


## Optional: get tile coords from world pos (for debugging or future spreading mechanic)
func get_tile_coords(world_pos: Vector2) -> Vector2i:
	return local_to_map(to_local(world_pos))
	
	

## -------------------------------------------------------------------------
## NEW: Check if a line between two world positions is blocked by walls
## -------------------------------------------------------------------------
func is_line_of_sight_clear(start_world: Vector2, end_world: Vector2, wall_layer: TileMapLayer) -> bool:
	# Convert to tilemap-local coordinates
	var start_local = wall_layer.to_local(start_world)
	var end_local = wall_layer.to_local(end_world)

	var start_cell = wall_layer.local_to_map(start_local)
	var end_cell   = wall_layer.local_to_map(end_local)

	# Bresenham line algorithm over tiles
	var dx = abs(end_cell.x - start_cell.x)
	var dy = abs(end_cell.y - start_cell.y)
	var sx = 1 if start_cell.x < end_cell.x else -1
	var sy = 1 if start_cell.y < end_cell.y else -1
	var err = dx - dy
	var current = start_cell

	while true:
		var tile_data = wall_layer.get_cell_tile_data(current)
		if tile_data != null:
			# You can decide what counts as "blocking"
			if tile_data.get_custom_data("is_wall") == true:
				return false

		if current == end_cell:
			break

		var e2 = 2 * err
		if e2 > -dy:
			err -= dy
			current.x += sx
		if e2 < dx:
			err += dx
			current.y += sy

	return true  # no blocking tiles found


## -------------------------------------------------------------------------
## NEW: Find nearest poison WITH LOS check
## -------------------------------------------------------------------------
func find_closest_poison_in_radius_with_LOS(
	origin_world_pos: Vector2,
	radius_in_tiles: int,
	wall_layer: WallLayer
) -> Vector2:

	var origin_local = to_local(origin_world_pos)
	var origin_cell  = local_to_map(origin_local)

	var best_dist = INF
	var best_world_pos = Vector2.INF

	for x in range(origin_cell.x - radius_in_tiles, origin_cell.x + radius_in_tiles + 1):
		for y in range(origin_cell.y - radius_in_tiles, origin_cell.y + radius_in_tiles + 1):
			var cell = Vector2i(x, y)
			var tile_data = get_cell_tile_data(cell)
			if tile_data == null:
				continue
			if not tile_data.get_custom_data("is_poison"):
				continue

			# convert to world pos
			var tile_local  = map_to_local(cell)
			var tile_world  = to_global(tile_local)

			# LOS CHECK HERE -----------------------------
			# Use wall_layer's LOS check
			if not wall_layer.is_line_of_sight_clear(origin_world_pos, tile_world):
				continue  # skip this poison tile
			# ---------------------------------------------

			var dist = origin_world_pos.distance_to(tile_world)
			if dist < best_dist:
				best_dist = dist
				best_world_pos = tile_world

	return best_world_pos

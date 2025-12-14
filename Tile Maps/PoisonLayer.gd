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
## Physics LOS: blocks by any collider on the given collision mask
## (Tiles with collision + Doors (StaticBody2D) + Any other obstacles)
## -------------------------------------------------------------------------
func is_line_of_sight_clear_physics(
	start_world: Vector2,
	end_world: Vector2,
	mask: int,
	exclude: Array = []
) -> bool:
	var space_state := get_world_2d().direct_space_state

	var params := PhysicsRayQueryParameters2D.create(start_world, end_world)
	params.collision_mask = mask
	params.exclude = exclude
	params.hit_from_inside = true

	var hit := space_state.intersect_ray(params)
	return hit.is_empty()


## -------------------------------------------------------------------------
## Find nearest poison WITH Physics LOS check
## Returns Vector2.INF if not found
## -------------------------------------------------------------------------
func find_closest_poison_in_radius_with_LOS(
	origin_world_pos: Vector2,
	radius_in_tiles: int,
	smell_collision_mask: int,
	exclude: Array = []
) -> Vector2:
	var origin_local := to_local(origin_world_pos)
	var origin_cell := local_to_map(origin_local)

	var best_dist := INF
	var best_world_pos := Vector2.INF

	for x in range(origin_cell.x - radius_in_tiles, origin_cell.x + radius_in_tiles + 1):
		for y in range(origin_cell.y - radius_in_tiles, origin_cell.y + radius_in_tiles + 1):
			var cell := Vector2i(x, y)

			var tile_data := get_cell_tile_data(cell)
			if tile_data == null:
				continue
			if not tile_data.get_custom_data("is_poison"):
				continue

			# Convert tile cell to world position
			var tile_local := map_to_local(cell)
			var tile_world := to_global(tile_local)

			# LOS check (physics ray)
			if not is_line_of_sight_clear_physics(origin_world_pos, tile_world, smell_collision_mask, exclude):
				continue

			var dist := origin_world_pos.distance_to(tile_world)
			if dist < best_dist:
				best_dist = dist
				best_world_pos = tile_world

	return best_world_pos

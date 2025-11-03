extends TileMapLayer
class_name BloodTileMapLayer

var blood_cells: Dictionary = {}
var blood_source_id: int = 0
var blood_atlas_coords: Vector2i = Vector2i(0, 1)

func _ready():
	initialize_existing_blood()

func initialize_existing_blood():
	var used_cells = get_used_cells()
	print("Blood初始化: ", used_cells.size(), " 个格子")
	for cell in used_cells:
		blood_cells[cell] = true

func add_blood(grid_pos: Vector2i):
	if not has_blood(grid_pos):
		blood_cells[grid_pos] = true
		set_cell(grid_pos, blood_source_id, blood_atlas_coords)

func has_blood(grid_pos: Vector2i) -> bool:
	return blood_cells.has(grid_pos)

func world_to_grid(world_pos: Vector2) -> Vector2i:
	return local_to_map(to_local(world_pos))

func grid_to_world(grid_pos: Vector2i) -> Vector2:
	return to_global(map_to_local(grid_pos))

extends Node2D

@onready var blood_map: TileMap = $BloodMap
var _blood := {} # {Vector2i: true}

func _world_to_cell(world_pos: Vector2) -> Vector2i:
	return blood_map.local_to_map(blood_map.to_local(world_pos))

func set_blood_cell(cell: Vector2i, present: bool) -> void:
	if present:
		_blood[cell] = true
		# set_cell(layer, coords, source_id, atlas_coords, alternative)
		blood_map.set_cell(0, cell, 0, Vector2i(0, 0), 0)
	else:
		_blood.erase(cell)
		# erase_cell(layer, coords)
		blood_map.erase_cell(0, cell)

func splat_world(world_pos: Vector2) -> void:
	set_blood_cell(_world_to_cell(world_pos), true)

func has_blood_cell(cell: Vector2i) -> bool:
	return _blood.has(cell)

func has_blood_at(world_pos: Vector2) -> bool:
	return has_blood_cell(_world_to_cell(world_pos))

func clear_all() -> void:
	_blood.clear()
	blood_map.clear()

extends Enemy
class_name PoisonHunter

# Poison layer (found via group)
@onready var poison_layer: PoisonLayer = get_tree().get_first_node_in_group("poison_layer")

# How far (in tiles) this enemy can smell poison
@export var smell_radius_tiles: int = 3

# Smell ray collision mask:
# "Walls" is layer 5 => Bit 4 => value 16
@export var smell_collision_mask: int = 16


## Find closest poison tile in smell radius, with physics LOS check.
## Returns Vector2.INF if no valid poison target.
func get_poison_target_world_pos() -> Vector2:
	if poison_layer == null:
		return Vector2.INF

	# Exclude self so the ray won't hit hunter's own colliders.
	var exclude := [self]

	return poison_layer.find_closest_poison_in_radius_with_LOS(
		global_position,
		smell_radius_tiles,
		smell_collision_mask,
		exclude
	)


## Direction handling (4-direction, no sprite flipping)
func set_direction(_new_direction: Vector2) -> bool:
	direction = _new_direction
	if direction == Vector2.ZERO:
		return false

	var direction_id: int = int(round(
		(direction + cardinal_direction * 0.1).angle()
		/ TAU * DIR_4.size()
	))
	var new_dir: Vector2 = DIR_4[direction_id]

	if new_dir == cardinal_direction:
		return false

	cardinal_direction = new_dir
	direction_changed.emit(new_dir)
	# No sprite flipping here, we use 4-direction animations instead
	return true


func anim_direction() -> String:
	if cardinal_direction == Vector2.DOWN:
		return "down"
	elif cardinal_direction == Vector2.UP:
		return "up"
	elif cardinal_direction == Vector2.LEFT:
		return "left"
	else:
		return "right"

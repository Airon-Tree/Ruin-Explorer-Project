extends Enemy
class_name BinaryPoisoner

# Whether this enemy is currently in "poison follow" mode
var poison_mode: bool = false

# Follow settings
@export var follow_distance: float = 32.0  # desired distance to player (in pixels)

# Reference to PoisonLayer so states can use it
@onready var poison_layer: PoisonLayer = get_tree().get_first_node_in_group("poison_layer")


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


## Toggle poison_mode on each non-lethal hit
func _take_damage(hurt_box: HurtBox) -> void:
	if invulnerable:
		return

	hp -= hurt_box.damage

	if hp > 0:
		poison_mode = not poison_mode
		enemy_damaged.emit(hurt_box)
	else:
		enemy_destoryed.emit(hurt_box)

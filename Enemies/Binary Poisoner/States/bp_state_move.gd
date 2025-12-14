extends EnemyState
class_name BPStateMove

@export var anim_name: String = "walk"
@export var move_speed: float = 20.0

# How far the enemy wants to stay from the player (in pixels)
@export var follow_distance: float = 32.0
@export var follow_tolerance: float = 8.0  # small dead-zone around follow distance

# Poison trail settings
@export var trail_step_distance: float = 16.0

# Where to go when poison_mode is turned off
@export var idle_state: EnemyState

# Tile info for poison floor
const POISON_SOURCE_ID := 0
const POISON_ATLAS_COORDS := Vector2i(35, 3)
const POISON_ALTERNATIVE_ID := 0

# Unstuck / sidestep settings
@export var stuck_distance_threshold: float = 0.2    # consider "not moved" if below this distance
@export var stuck_time_before_sidestep: float = 2.0  # how long to be stuck before sidestep (sec)
@export var sidestep_speed: float = 60.0             # speed while sidestepping
@export var sidestep_duration: float = 0.8           # how long a sidestep lasts (sec)

var bp: BinaryPoisoner

var _last_pos: Vector2
var _stuck_time: float = 0.0

var _sidestep_timer: float = 0.0
var _sidestep_dir: Vector2 = Vector2.ZERO

var _last_trail_pos: Vector2
var _trail_initialized: bool = false


func init() -> void:
	# Cast generic enemy reference to our BinaryPoisoner
	bp = enemy as BinaryPoisoner


func enter() -> void:
	if bp == null:
		return

	bp.update_animation(anim_name)
	_last_pos = bp.global_position
	_stuck_time = 0.0
	_sidestep_timer = 0.0
	_sidestep_dir = Vector2.ZERO

	_last_trail_pos = bp.global_position
	_trail_initialized = true


func exit() -> void:
	if bp:
		bp.velocity = Vector2.ZERO


func process(delta: float) -> EnemyState:
	if bp == null:
		return null

	# 0) If poison mode was turned off (second hit), go back to Idle state
	if not bp.poison_mode:
		return idle_state

	# 1) If there is no player to follow, just stand still
	if bp.player == null:
		bp.velocity = Vector2.ZERO
		return null

	var to_player: Vector2 = bp.player.global_position - bp.global_position
	var dist: float = to_player.length()
	var dir: Vector2 = Vector2.ZERO

	if dist > follow_distance + follow_tolerance:
		# Too far → move towards player
		dir = to_player.normalized()
	elif dist < follow_distance - follow_tolerance:
		# Too close → move slightly away
		dir = -to_player.normalized()
	else:
		# In comfortable range → no forward/back movement
		dir = Vector2.ZERO

	# 2) Movement: chase with sidestep unstuck
	if _sidestep_timer > 0.0 and _sidestep_dir != Vector2.ZERO:
		# Currently sidestepping
		_sidestep_timer -= delta
		_handle_sidestep_movement()
	else:
		# Normal follow movement
		_sidestep_timer = 0.0
		_sidestep_dir = Vector2.ZERO

		if dir != Vector2.ZERO:
			bp.velocity = dir * move_speed
			bp.set_direction(dir)
			bp.update_animation(anim_name)
			_update_stuck_state(delta, dir)
		else:
			bp.velocity = Vector2.ZERO
			_stuck_time = 0.0  # not trying to move, so not "stuck"

	# 3) Leave poison behind based on movement
	_leave_poison_trail()

	# 4) Update last position
	_last_pos = bp.global_position

	return null  # stay in BP_Move


func physics(_delta: float) -> EnemyState:
	return null


## -----------------------------
## Stuck / sidestep helpers
## -----------------------------
func _update_stuck_state(delta: float, dir: Vector2) -> void:
	var moved_dist := bp.global_position.distance_to(_last_pos)

	# If we are basically not moving while trying to follow, accumulate stuck time
	if moved_dist < stuck_distance_threshold and bp.velocity.length() > 0.0:
		_stuck_time += delta
	else:
		_stuck_time = 0.0

	if _stuck_time >= stuck_time_before_sidestep:
		_start_sidestep(dir)
		_stuck_time = 0.0


func _start_sidestep(follow_dir: Vector2) -> void:
	# Choose a perpendicular direction to follow_dir (left or right)
	var perp_left := Vector2(-follow_dir.y, follow_dir.x)
	var perp_right := Vector2(follow_dir.y, -follow_dir.x)

	_sidestep_dir = perp_left if randf() < 0.5 else perp_right
	_sidestep_dir = _sidestep_dir.normalized()
	_sidestep_timer = sidestep_duration

	_handle_sidestep_movement()


func _handle_sidestep_movement() -> void:
	if bp == null or _sidestep_dir == Vector2.ZERO:
		return
	bp.velocity = _sidestep_dir * sidestep_speed
	bp.set_direction(_sidestep_dir)
	bp.update_animation(anim_name)


## -----------------------------
## Poison trail helpers
## -----------------------------
func _leave_poison_trail() -> void:
	if bp.poison_layer == null:
		return

	if not _trail_initialized:
		_last_trail_pos = bp.global_position
		_trail_initialized = true

	var dist := bp.global_position.distance_to(_last_trail_pos)
	if dist < trail_step_distance:
		return  # not far enough yet

	# Use the previous position as the trail point so poison appears "behind" the enemy
	var trail_world_pos: Vector2 = _last_trail_pos

	# Convert to cell coords
	var local_pos: Vector2 = bp.poison_layer.to_local(trail_world_pos)
	var cell: Vector2i = bp.poison_layer.local_to_map(local_pos)

	bp.poison_layer.set_cell(cell, POISON_SOURCE_ID, POISON_ATLAS_COORDS, POISON_ALTERNATIVE_ID)

	_last_trail_pos = bp.global_position

class_name PHStateMove
extends EnemyState

@export var anim_name: String = "walk"
@export var move_speed: float = 40.0
@export var chase_speed: float = 100.0
@export var chase_player_radius: float = 200.0  # how far to chase the player when no poison

# Wander / idle settings when no target is found
@export var wander_speed: float = 20.0
@export var wander_time_min: float = 0.6
@export var wander_time_max: float = 1.5
@export_range(0.0, 1.0) var idle_chance: float = 0.35  # chance to idle instead of wandering
@export var idle_state : EnemyState

# Unstuck / sidestep settings
@export var stuck_distance_threshold: float = 0.5    # consider "not moved" if below this distance
@export var stuck_time_before_sidestep: float = 2.0  # how long to be stuck before sidestep
@export var sidestep_speed: float = 40.0             # speed while sidestepping
@export var sidestep_duration: float = 0.8           # how long a sidestep lasts

var hunter: PoisonHunter

var _wander_dir: Vector2 = Vector2.ZERO
var _wander_timer: float = 0.0

var _last_pos: Vector2
var _stuck_time: float = 0.0

var _sidestep_timer: float = 0.0
var _sidestep_dir: Vector2 = Vector2.ZERO


func init() -> void:
	# Cast the generic "enemy" reference to PoisonHunter
	hunter = enemy as PoisonHunter


func enter() -> void:
	if hunter:
		hunter.update_animation(anim_name)
		_last_pos = hunter.global_position
		_stuck_time = 0.0
		_sidestep_timer = 0.0
		_sidestep_dir = Vector2.ZERO


func exit() -> void:
	if hunter:
		hunter.velocity = Vector2.ZERO


func process(delta: float) -> EnemyState:
	if hunter == null:
		return null
		
	# 0) If standing on a poison tile, clean it
	if hunter.poison_layer != null and hunter.poison_layer.is_poison_at_world_pos(hunter.global_position):
		var cell: Vector2i = hunter.poison_layer.get_tile_coords(hunter.global_position)
		hunter.poison_layer.erase_cell(cell)  # remove poison tile
		hunter.velocity = Vector2.ZERO
		# Reset stuck state after "eating"
		_stuck_time = 0.0
		_sidestep_timer = 0.0
		_sidestep_dir = Vector2.ZERO
		_last_pos = hunter.global_position
		return null

	var dir: Vector2 = Vector2.ZERO
	
	# 1) Try to chase poison first
	var poison_pos: Vector2 = hunter.get_poison_target_world_pos()
	if poison_pos != Vector2.INF:
		dir = (poison_pos - hunter.global_position).normalized()
	else:
		# 2) No poison in smell radius → try to chase player
		if hunter.player != null:
			var to_player: Vector2 = hunter.player.global_position - hunter.global_position
			if to_player.length() <= chase_player_radius:
				dir = to_player.normalized()

	# 3) If we have a real target (poison or player), use chase logic
	if dir != Vector2.ZERO:
		# While we are in sidestep mode, ignore direct chase dir
		if _sidestep_timer > 0.0 and _sidestep_dir != Vector2.ZERO:
			_sidestep_timer -= delta
			_handle_sidestep_movement()
		else:
			# Normal chase movement
			_sidestep_timer = 0.0
			_sidestep_dir = Vector2.ZERO

			var speed := move_speed
			if poison_pos == Vector2.INF and hunter.player != null:
				# chasing player
				speed = chase_speed

			hunter.velocity = dir * speed
			hunter.set_direction(dir)
			hunter.update_animation(anim_name)

			_update_stuck_state(delta, dir)
	else:
		# 4) No poison and no player in range → wander / maybe go idle
		var next_state := _wander_or_try_idle(delta)
		# Wander/idle should not use chase stuck logic
		_stuck_time = 0.0
		_sidestep_timer = 0.0
		_sidestep_dir = Vector2.ZERO
		_last_pos = hunter.global_position
		return next_state

	# Update last position for next frame
	_last_pos = hunter.global_position
	return null  # stay in this state


func physics(_delta: float) -> EnemyState:
	return null


## -----------------------------
## Stuck / sidestep helpers
## -----------------------------
func _update_stuck_state(delta: float, dir: Vector2) -> void:
	# Measure how far we moved since last frame
	var moved_dist := hunter.global_position.distance_to(_last_pos)

	# If we are basically not moving while trying to chase, accumulate stuck time
	if moved_dist < stuck_distance_threshold and hunter.velocity.length() > 0.0:
		_stuck_time += delta
	else:
		_stuck_time = 0.0

	# If we've been stuck for long enough, start a sidestep
	if _stuck_time >= stuck_time_before_sidestep:
		_start_sidestep(dir)
		_stuck_time = 0.0


func _start_sidestep(chase_dir: Vector2) -> void:
	# Choose a perpendicular direction to chase_dir (left or right)
	var perp_left := Vector2(-chase_dir.y, chase_dir.x)
	var perp_right := Vector2(chase_dir.y, -chase_dir.x)

	# Randomly pick left or right
	_sidestep_dir = perp_left if randf() < 0.5 else perp_right
	_sidestep_dir = _sidestep_dir.normalized()
	_sidestep_timer = sidestep_duration

	# Apply initial sidestep velocity
	_handle_sidestep_movement()


func _handle_sidestep_movement() -> void:
	if hunter == null or _sidestep_dir == Vector2.ZERO:
		return
	hunter.velocity = _sidestep_dir * sidestep_speed
	hunter.set_direction(_sidestep_dir)
	hunter.update_animation(anim_name)


## -----------------------------
## Wander / Idle helper
## -----------------------------
func _wander_or_try_idle(delta: float) -> EnemyState:
	if hunter == null:
		return null

	# If we are currently in a wander phase
	if _wander_timer > 0.0 and _wander_dir != Vector2.ZERO:
		_wander_timer -= delta
		hunter.velocity = _wander_dir * wander_speed
		hunter.set_direction(_wander_dir)
		hunter.update_animation(anim_name)
		return null

	# Wander timer finished or not set → choose next behavior
	_wander_timer = 0.0
	_wander_dir = Vector2.ZERO

	# Decide whether to go to Idle state
	if idle_state != null and randf() < idle_chance:
		return idle_state

	# Otherwise, pick a new random wander direction
	var idx := randi_range(0, hunter.DIR_4.size() - 1)
	_wander_dir = hunter.DIR_4[idx]
	_wander_timer = randf_range(wander_time_min, wander_time_max)

	hunter.velocity = _wander_dir * wander_speed
	hunter.set_direction(_wander_dir)
	hunter.update_animation(anim_name)

	return null

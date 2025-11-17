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

var hunter: PoisonHunter

var _wander_dir: Vector2 = Vector2.ZERO
var _wander_timer: float = 0.0

func init() -> void:
	# Cast the generic "enemy" reference to PoisonHunter
	hunter = enemy as PoisonHunter


func enter() -> void:
	if hunter:
		hunter.update_animation(anim_name)


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
		# Stop movement this frame so he doesn't "slide" past after eating
		hunter.velocity = Vector2.ZERO
		# You can choose whether to return here or continue; returning makes him "pause" after eating.
		return null

	var dir: Vector2 = Vector2.ZERO
	
	# 1) Try to chase poison first
	var poison_pos: Vector2 = hunter.get_poison_target_world_pos()
	if poison_pos != Vector2.INF:
		dir = (poison_pos - hunter.global_position).normalized()
		hunter.velocity = dir * move_speed
	else:
		# 2) No poison in smell radius → try to chase player
		if hunter.player != null:
			var to_player: Vector2 = hunter.player.global_position - hunter.global_position
			if to_player.length() <= chase_player_radius:
				dir = to_player.normalized()
				hunter.velocity = dir * chase_speed

	# 3) Apply movement if we have a target direction
	if dir != Vector2.ZERO:
		# Reset wander state because we are in active chase mode
		_wander_timer = 0.0
		_wander_dir = Vector2.ZERO
		
		hunter.set_direction(dir)
		hunter.update_animation(anim_name)
		return null  # stay in PH_Move state
	else:
		# 4) No poison and no player in range → wander / maybe go idle
		var next_state := _wander_or_try_idle(delta)
		return next_state

	#return null  # stay in this state; EnemyStateMachine keeps us here


func physics(_delta: float) -> EnemyState:
	return null

## -----------------------------
## Wander / Idle helper
## -----------------------------
func _wander_or_try_idle(delta: float) -> EnemyState:
	if hunter == null:
		return null

	# If we are currently in a wander phase
	if _wander_timer > 0.0 and _wander_dir != Vector2.ZERO:
		_wander_timer -= delta
		# keep wandering in current direction
		hunter.velocity = _wander_dir * wander_speed
		hunter.set_direction(_wander_dir)
		hunter.update_animation(anim_name)
		return null

	# Wander timer finished or not set → choose next behavior
	_wander_timer = 0.0
	_wander_dir = Vector2.ZERO

	# Decide whether to go to Idle state
	if idle_state != null and randf() < idle_chance:
		# Let EnemyStateMachine switch to the Idle state
		return idle_state

	# Otherwise, pick a new random wander direction
	var idx := randi_range(0, hunter.DIR_4.size() - 1)
	_wander_dir = hunter.DIR_4[idx]
	_wander_timer = randf_range(wander_time_min, wander_time_max)

	hunter.velocity = _wander_dir * wander_speed
	hunter.set_direction(_wander_dir)
	hunter.update_animation(anim_name)

	return null

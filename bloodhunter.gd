extends CharacterBody2D
class_name BloodHunter

@export var speed: float = 50.0
@export var chase_speed: float = 80.0
@export var vision_range: float = 200.0
@export var turn_interval_min: float = 1.0
@export var turn_interval_max: float = 2.0
@export var spit_interval: float = 2.0

var blood_layer: BloodTileMapLayer
var wall_layer: TileMapLayer
var obstacle_layer: TileMapLayer
var player: CharacterBody2D
var current_grid_pos: Vector2i

var vision_check_timer: float = 0.0
var turn_timer: float = 0.0
var spit_timer: float = 0.0
var next_turn_time: float = 0.0
var can_see_player_cached: bool = false
var current_direction: Vector2 = Vector2.ZERO
var last_direction: Vector2 = Vector2.ZERO  # 记录上一次的移动方向
var last_position: Vector2
var stuck_timer: float = 0.0
var at_edge_timer: float = 0.0
var just_hit_wall: bool = false  # 刚撞墙的标记

func _ready():
	var blood_nodes = get_tree().get_nodes_in_group("blood_layer")
	if blood_nodes.size() > 0:
		blood_layer = blood_nodes[0]
	
	var wall_nodes = get_tree().get_nodes_in_group("wall_layer")
	if wall_nodes.size() > 0:
		wall_layer = wall_nodes[0]
	
	var obstacle_nodes = get_tree().get_nodes_in_group("obstacle_layer")
	if obstacle_nodes.size() > 0:
		obstacle_layer = obstacle_nodes[0]
	
	var player_nodes = get_tree().get_nodes_in_group("player")
	if player_nodes.size() > 0:
		player = player_nodes[0]
	
	last_position = global_position
	choose_random_direction()
	set_random_turn_time()

func _physics_process(delta):
	update_grid_position()
	
	if not blood_layer.has_blood(current_grid_pos):
		turn_back_to_blood()
		stuck_timer = 0.0
		return
	
	# 检测卡住
	var distance_moved = global_position.distance_to(last_position)
	var expected_min_move = speed * delta * 0.3
	
	if distance_moved < expected_min_move:
		stuck_timer += delta
		if stuck_timer > 0.05:
			# 撞墙了！
			just_hit_wall = true
			last_direction = current_direction  # 记录撞墙前的方向
			turn_random()
			stuck_timer = 0.0
	else:
		stuck_timer = 0.0
		just_hit_wall = false
	
	last_position = global_position
	
	# 视线检测
	vision_check_timer += delta
	if vision_check_timer >= 0.5:
		vision_check_timer = 0.0
		can_see_player_cached = check_can_see_player()
	
	# 喷血计时
	spit_timer += delta
	if spit_timer >= spit_interval:
		spit_timer = 0.0
		spit_blood()
	
	# AI行为
	if can_see_player_cached:
		chase_mode(delta)
	else:
		at_edge_timer = 0.0
		wander_mode(delta)
	
	move_and_slide()

func update_grid_position():
	current_grid_pos = blood_layer.world_to_grid(global_position)

func turn_back_to_blood():
	var directions = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
	
	for dir in directions:
		var check_pos = current_grid_pos + dir
		if blood_layer.has_blood(check_pos):
			current_direction = Vector2(dir)
			velocity = current_direction * speed
			move_and_slide()
			return
	
	velocity = Vector2.ZERO

func check_can_see_player() -> bool:
	if player == null:
		return false
	
	var distance = global_position.distance_to(player.global_position)
	if distance > vision_range:
		return false
	
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.new()
	query.from = global_position
	query.to = player.global_position
	query.exclude = [self]
	query.collision_mask = 0xFFFFFFFF
	
	var result = space_state.intersect_ray(query)
	
	if not result.is_empty():
		return result.collider == player
	
	return true

func chase_mode(delta):
	if player == null:
		return
	
	var player_grid = blood_layer.world_to_grid(player.global_position)
	var player_on_blood = blood_layer.has_blood(player_grid)
	
	var direction_to_player = (player.global_position - global_position).normalized()
	
	var chase_dir = Vector2.ZERO
	if abs(direction_to_player.x) > abs(direction_to_player.y):
		chase_dir = Vector2(sign(direction_to_player.x), 0)
	else:
		chase_dir = Vector2(0, sign(direction_to_player.y))
	
	var next_grid = current_grid_pos + Vector2i(chase_dir.x, chase_dir.y)
	var can_move_forward = blood_layer.has_blood(next_grid)
	
	if player_on_blood:
		current_direction = chase_dir
		velocity = chase_dir * chase_speed
		at_edge_timer = 0.0
	else:
		if can_move_forward:
			current_direction = chase_dir
			velocity = chase_dir * chase_speed
			at_edge_timer = 0.0
		else:
			at_edge_timer += delta
			
			if at_edge_timer > 0.5:
				velocity = Vector2.ZERO
				current_direction = Vector2.ZERO
			else:
				velocity = velocity * 0.5

func wander_mode(delta):
	turn_timer += delta
	
	if turn_timer >= next_turn_time:
		turn_timer = 0.0
		set_random_turn_time()
		turn_random()
	
	if current_direction != Vector2.ZERO:
		velocity = current_direction * speed
	else:
		choose_random_direction()

func set_random_turn_time():
	next_turn_time = randf_range(turn_interval_min, turn_interval_max)

func turn_random():
	var directions = [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN]
	var available_dirs = []
	
	for dir in directions:
		var test_pos = global_position + dir * 5
		available_dirs.append(dir)
	
	if available_dirs.size() > 0:
		current_direction = available_dirs[randi() % available_dirs.size()]
	else:
		current_direction = directions[randi() % directions.size()]
	
	velocity = current_direction * speed

func choose_random_direction():
	var directions = [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN]
	current_direction = directions[randi() % directions.size()]
	velocity = current_direction * speed

func spit_blood():
	if just_hit_wall and last_direction != Vector2.ZERO:
		# 刚撞墙，朝撞墙前的方向喷血
		var spit_grid = current_grid_pos + Vector2i(round(last_direction.x), round(last_direction.y))
		
		# 检查是否可以喷
		if not blood_layer.has_blood(spit_grid) and is_grid_walkable(spit_grid):
			blood_layer.add_blood(spit_grid)
			print("撞墙后喷血到: ", spit_grid, " 方向: ", last_direction)
		else:
			print("撞墙方向有障碍物，无法喷血")
	else:
		# 没撞墙，正常喷血（边缘方向）
		spit_at_edge()

func spit_at_edge():
	var directions = [
		Vector2i.RIGHT,
		Vector2i.LEFT,
		Vector2i.UP,
		Vector2i.DOWN
	]
	
	var edge_dirs = []
	for dir in directions:
		var check_grid = current_grid_pos + dir
		
		if not blood_layer.has_blood(check_grid) and is_grid_walkable(check_grid):
			edge_dirs.append(dir)
	
	if edge_dirs.size() > 0:
		var spit_dir = edge_dirs[randi() % edge_dirs.size()]
		var spit_pos = current_grid_pos + spit_dir
		blood_layer.add_blood(spit_pos)

func is_grid_walkable(grid_pos: Vector2i) -> bool:
	var world_pos = blood_layer.grid_to_world(grid_pos)
	
	if wall_layer != null:
		var wall_grid = wall_layer.local_to_map(wall_layer.to_local(world_pos))
		if wall_layer.get_cell_source_id(wall_grid) != -1:
			return false
	
	if obstacle_layer != null:
		var obs_grid = obstacle_layer.local_to_map(obstacle_layer.to_local(world_pos))
		if obstacle_layer.get_cell_source_id(obs_grid) != -1:
			return false
	
	return true

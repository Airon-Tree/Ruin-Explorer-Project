class_name MimicEnemy
extends Enemy

enum MimicState { DISGUISED, WINDUP, CHOMP, COOLDOWN }

@export_group("Disguise")
@export var disguise_sprites: Array[Texture2D]
@export var glow_color: Color = Color(1, 1, 0.5, 0.4)

@export_group("Behavior")
@export var detection_radius: float = 64.0
@export var windup_time: float = 0.6
@export var chomp_duration: float = 0.4
@export var cooldown_time: float = 0.5
@export var chomp_damage: int = 10
@export var chomp_radius: float = 64.0

@export_group("Teleport Targets")
@export var tilemap_layer_path: NodePath
@export var wall_layer_path: NodePath
@export var poison_layer_path: NodePath	


@onready var _sprite: Sprite2D = $Sprite2D
@onready var _glow_sprite: Sprite2D = $GlowSprite
@onready var _detection_area: Area2D = $DetectionArea
@onready var _detection_shape: CollisionShape2D = $DetectionArea/CollisionShape2D
@onready var _chomp_hurt_box: HurtBox = $ChompHurtBox
@onready var _chomp_shape: CollisionShape2D = $ChompHurtBox/CollisionShape2D
@onready var _warning_audio: AudioStreamPlayer2D = $WarningAudio
@onready var _chomp_audio: AudioStreamPlayer2D = $ChompAudio
@onready var _anim_player: AnimationPlayer = $AnimationPlayer


var _state: MimicState = MimicState.DISGUISED
var _busy: bool = false


func _ready() -> void:
	super()

	randomize()


	if _detection_shape and _detection_shape.shape is CircleShape2D:
		var circle := _detection_shape.shape as CircleShape2D
		circle.radius = detection_radius


	if _chomp_shape and _chomp_shape.shape is CircleShape2D:
		var chomp_circle := _chomp_shape.shape as CircleShape2D
		chomp_circle.radius = chomp_radius


	if _chomp_hurt_box:
		_chomp_hurt_box.damage = chomp_damage
		_chomp_hurt_box.monitoring = false
		_chomp_hurt_box.visible = false


	if _glow_sprite:
		_glow_sprite.modulate = glow_color
		#_glow_sprite.visible = true

	_detection_area.body_entered.connect(_on_detection_body_entered)

	_enter_disguised_state()


func _enter_disguised_state() -> void:
	_state = MimicState.DISGUISED
	_busy = false
	velocity = Vector2.ZERO
	_pick_random_disguise()


func _pick_random_disguise() -> void:
	#print("enter _pick_random_disguise")
	if _sprite == null or disguise_sprites.is_empty():
		#print("no sprite for ankang")
		return
	var idx := randi() % disguise_sprites.size()
	#print("idx: ", idx)
	_sprite.texture = disguise_sprites[idx]


func _on_detection_body_entered(body: Node) -> void:
	if _busy:
		return
	if _state != MimicState.DISGUISED:
		return
	if not (body is Player or body is Enemy):
		return
	if body == self:
		return

	_start_attack_sequence()


func _start_attack_sequence() -> void:
	_busy = true
	_state = MimicState.WINDUP

	if _warning_audio:
		_warning_audio.play()

	await get_tree().create_timer(windup_time).timeout
	if not is_inside_tree():
		return

	_do_chomp()

	await get_tree().create_timer(chomp_duration).timeout
	if not is_inside_tree():
		return

	_end_chomp_and_teleport()


func _do_chomp() -> void:
	_state = MimicState.CHOMP

	if _chomp_hurt_box:
		_chomp_hurt_box.monitoring = true
		_chomp_hurt_box.visible = true
	if _chomp_shape:
		_chomp_shape.disabled = false

	if _chomp_audio:
		_chomp_audio.play()
		
	#if _anim_player and _anim_player.has_animation("chomp_down"):
	#	_anim_player.play("chomp_down")
	if _anim_player and _anim_player.has_animation("test"):
		_anim_player.play("test")


func _end_chomp_and_teleport() -> void:
	if _chomp_hurt_box:
		_chomp_hurt_box.monitoring = false
		_chomp_hurt_box.visible = false
	if _chomp_shape:
		_chomp_shape.disabled = true

	_state = MimicState.COOLDOWN

	_teleport_to_safe_tile()

	await get_tree().create_timer(cooldown_time).timeout
	if not is_inside_tree():
		return

	_enter_disguised_state()


func _teleport_to_safe_tile() -> void:
	var tilemap := _get_tilemap_layer()
	if tilemap == null:
		return

	var used_cells := tilemap.get_used_cells()
	if used_cells.is_empty():
		return

	var wall_layer := _get_wall_layer()
	var poison_layer := _get_poison_layer()

	var safe_positions: Array[Vector2] = []

	for cell in used_cells:
		var local_pos: Vector2 = tilemap.map_to_local(cell)
		var world_pos: Vector2 = tilemap.to_global(local_pos)


		if wall_layer and wall_layer.is_wall_at_world_pos(world_pos):
			continue


		if poison_layer and poison_layer.get_dps_at_world_pos(world_pos) > 0.0:
			continue

		safe_positions.append(world_pos)

	if safe_positions.is_empty():
		return

	global_position = safe_positions[randi() % safe_positions.size()]


func _get_tilemap_layer() -> TileMapLayer:
	if tilemap_layer_path == NodePath(""):
		return null
	var node := get_node_or_null(tilemap_layer_path)
	if node is TileMapLayer:
		return node as TileMapLayer
	return null


func _get_wall_layer() -> WallLayer:
	if wall_layer_path == NodePath(""):
		return null
	var node := get_node_or_null(wall_layer_path)
	if node is WallLayer:
		return node as WallLayer
	return null


func _get_poison_layer() -> PoisonLayer:
	if poison_layer_path == NodePath(""):
		return null
	var node := get_node_or_null(poison_layer_path)
	if node is PoisonLayer:
		return node as PoisonLayer
	return null

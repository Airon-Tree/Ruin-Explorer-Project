class_name Player
extends CharacterBody2D

signal direction_changed( new_direction : Vector2)
signal player_damaged( hurt_box: HurtBox )

const DIR_4 = [ Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP ]

var cardinal_direction : Vector2 = Vector2.DOWN
var direction : Vector2 = Vector2.ZERO

var invulnerable : bool = false
var hp : int = 10
var max_hp : int = 10
var speed_boost_multiplier: float = 1.0

var is_dead: bool = false
@onready var death_sfx: AudioStreamPlayer2D = $Audio/DeathSFX

@onready var effect_animation_player: AnimationPlayer = $EffectAnimationPlayer
@onready var animation_player : AnimationPlayer = $AnimatedSprite2D/AnimationPlayer
@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var state_machine = $StateMachine
@onready var hit_box: HitBox = $HitBox

@onready var poison_layer: PoisonLayer = (
	get_tree().get_first_node_in_group("poison_layer") as PoisonLayer
)
@onready var poison_timer: Timer = $PoisonTickTimer



func _ready():
	PlayerManager.player = self
	state_machine.initialize(self)
	hit_box.damaged.connect( _take_damage )
	poison_timer.timeout.connect(_on_poison_tick)
	hp = max_hp
	PlayerHud.update_hp(hp, max_hp)
	pass
	
func _process(_delta):
	if is_dead:
		return
	#direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	#direction.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	direction = Vector2(
		Input.get_axis("left", "right"),
		Input.get_axis("up", "down")
	).normalized()
	
	pass

func _physics_process(_delta: float) -> void:
	move_and_slide()
	_check_poison(_delta)

func _check_poison(delta: float) -> void:
	if poison_layer == null:
		return

	var dps := poison_layer.get_dps_at_world_pos(global_position)

	if dps > 0:
		_enter_poison()
	else:
		_exit_poison()

func _enter_poison() -> void:
	# If timer is already running, do nothing
	if poison_timer.is_stopped():
		poison_timer.start()

func _exit_poison() -> void:
	# Stop the ticking when player leaves poison
	if not poison_timer.is_stopped():
		poison_timer.stop()

func _on_poison_tick() -> void:
	var dps := poison_layer.get_dps_at_world_pos(global_position)
	_take_poison_damage(dps)

func _take_poison_damage(amount: float) -> void:
	# Convert float poison damage to int
	var dmg: int = int(ceil(amount))
	if dmg <= 0:
		return
	if hp - dmg > 0:
		update_hp(-dmg)
	else:
		update_hp(9)
	effect_animation_player.play("damaged")


func set_direction() -> bool:
	var new_dir : Vector2 = cardinal_direction
	if direction == Vector2.ZERO:
		return false
		
	if direction.y == 0:
		new_dir = Vector2.LEFT if direction.x < 0 else Vector2.RIGHT
	elif direction.x == 0:
		new_dir = Vector2.UP if direction.y < 0 else Vector2.DOWN
		
	if new_dir == cardinal_direction:
		return false
	
	
	
	cardinal_direction = new_dir
	direction_changed.emit( new_dir )
	sprite.scale.x = -1 if cardinal_direction == Vector2.LEFT else 1
	return true
	
	
func update_animation( state : String) -> void:
	animation_player.play( state + "_" + anim_direction())
	pass
	
func anim_direction() -> String:
	if cardinal_direction == Vector2.DOWN:
		return "down"
	elif cardinal_direction == Vector2.UP:
		return "up"
	else:
		return "side"
		
		
func _take_damage( hurt_box : HurtBox) -> void:
	if invulnerable == true:
		return
	update_hp( -hurt_box.damage )
	if hp > 0:
		player_damaged.emit( hurt_box )
	else:
		player_damaged.emit( hurt_box )
		_on_player_death()
	pass
	
func update_hp( delta : int ) -> void:
	hp = clampi( hp + delta, 0, max_hp )
	PlayerHud.update_hp( hp, max_hp )
	pass

func _on_player_death() -> void:
	
	# Prevent double-trigger if something hits again at 0 HP
	if is_dead:
		return
	is_dead = true
	
	direction = Vector2.ZERO
	velocity = Vector2.ZERO
	
	if state_machine:
		state_machine.process_mode = Node.PROCESS_MODE_DISABLED
	
	# disable HitBox so enemies stop
	if hit_box:
		hit_box.monitoring = false
	
	if death_sfx:
		death_sfx.play()
	
	# game keep running for 1 second
	await get_tree().create_timer(1.0).timeout
	
	var ui_node := get_tree().current_scene.get_node_or_null("WinLoseScreen")
	if ui_node is WinLoseScreen:
		var screen := ui_node as WinLoseScreen
		screen.show_death()
	else:
		get_tree().reload_current_scene()
		
		
func reset_after_death() -> void:
	# Clear death flag
	is_dead = false
	
	direction = Vector2.ZERO
	velocity = Vector2.ZERO
	
	invulnerable = false
	if hit_box:
		hit_box.monitoring = true
	
	if state_machine:
		state_machine.process_mode = Node.PROCESS_MODE_INHERIT
	
	var delta_hp: int = max_hp - hp
	if delta_hp != 0:
		update_hp(delta_hp)


func apply_speed_boost(multiplier: float, duration: float) -> void:
	speed_boost_multiplier = multiplier
	_run_speed_boost_timer(duration)


func _run_speed_boost_timer(duration: float) -> void:
	await get_tree().create_timer(duration).timeout
	speed_boost_multiplier = 1.0
	
	
func make_invulnerable( _duration : float = 1.0 ) -> void:
	invulnerable = true
	hit_box.monitoring = false
	
	await get_tree().create_timer( _duration ).timeout
	
	invulnerable = false
	hit_box.monitoring = true
	pass
	
	

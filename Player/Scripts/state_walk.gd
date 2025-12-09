class_name State_Walk
extends State

@export var move_speed: float = 85.0
@export var run_speed_multiplier: float = 1.6

@onready var idle: State = $"../Idle"
@onready var attack: State = $"../Attack"


func enter() -> void:
	player.update_animation("walk")
	pass


func exit() -> void:
	pass


func process(_delta: float) -> State:
	if player.direction == Vector2.ZERO:
		player.velocity = Vector2.ZERO
		return idle
	
	# Base speed from state, multiplied by current buff
	var speed: float = move_speed * player.speed_boost_multiplier
	
	# Hold Shift to "run"
	if Input.is_action_pressed("run"):
		speed *= run_speed_multiplier
	
	player.velocity = player.direction * speed
	
	if player.set_direction():
		player.update_animation("walk")
	
	return null


func physics(_delta: float) -> State:
	return null


func handle_input(_event: InputEvent) -> State:
	if _event.is_action_pressed("attack"):
		return attack
	return null

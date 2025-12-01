class_name State_Walk
extends State

@export var move_speed : float = 100.0
@export var run_speed_multiplier : float = 1.5
@export var run_anim_speed_multiplier : float = 1.5

@onready var idle : State = $"../Idle"
@onready var attack : State = $"../Attack"


func enter() -> void:
	player.update_animation("walk")
	if player.sprite:
		player.sprite.speed_scale = 1.0
	pass
	
func exit() -> void:
	if player.sprite:
		player.sprite.speed_scale = 1.0
	pass
	
func process( _delta : float ) -> State:
	if player.direction == Vector2.ZERO:
		if player.sprite:
			player.sprite.speed_scale = 1.0
		return idle
	
	
	var speed := move_speed
	var anim_speed := 1.0
	
	if Input.is_action_pressed("run"):
		speed *= run_speed_multiplier
		anim_speed = run_anim_speed_multiplier
	
	player.velocity = player.direction * speed
	
	if player.sprite:
		player.sprite.speed_scale = anim_speed
	
	if player.set_direction():
		player.update_animation("walk")
	
	return null

func physics(_delta : float ) -> State:
	return null
	
func handle_input( _event: InputEvent ) -> State:
	if _event.is_action_pressed("attack"):
		return attack
	return null 

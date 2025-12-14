class_name State_Idle
extends State

@onready var walk : State = $"../Walk"
@onready var attack : State = $"../Attack"


func enter() -> void:
	player.update_animation("idle")
	pass
	
func exit() -> void:
	pass
	
func process( _delta : float ) -> State:
	if player.direction != Vector2.ZERO:
		return walk
	player.velocity = Vector2.ZERO
	#regen stamina faster when idle
	player.update_stamina_value(_delta, false, player.idle_regen_multiplier)
	return null

func physics(_delta : float ) -> State:
	return null
	
func handle_input( _event: InputEvent ) -> State:
	if _event.is_action_pressed("attack"):
		return attack
	return null 

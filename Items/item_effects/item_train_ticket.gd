class_name ItemDataTrainTicket
extends ItemEffect

@export var power: int = 1        # how strong this ticket is (1..4 lights)
@export var base_heal: int = 1
@export var heal_per_power: int = 2
@export var base_duration: float = 2.0
@export var duration_per_power: float = 1.5
@export var base_speed_mult: float = 1.4
@export var speed_mult_per_power: float = 0.2

@export var audio : AudioStream


func use() -> void:
	var total_power: int = max(power, 0)
	
	var heal_amount: int = base_heal + heal_per_power * total_power
	var speed_multiplier: float = base_speed_mult + speed_mult_per_power * float(total_power)
	var duration: float = base_duration + duration_per_power * float(total_power)
	
	PlayerManager.player.update_hp(heal_amount)
	PlayerManager.player.apply_speed_boost(speed_multiplier, duration)
	
	PauseMenu.play_audio( audio )
	

extends Node2D

func _ready() -> void:
	visible = false
	#if PlayerManager.player_spawned == false:
		#PlayerManager.set_player_position( global_position )
		#PlayerManager.player_spawned = true
		
	if LevelManager.target_transition != "" and name != LevelManager.target_transition:
		return
	
	PlayerManager.set_player_position(global_position + LevelManager.position_offset)
		

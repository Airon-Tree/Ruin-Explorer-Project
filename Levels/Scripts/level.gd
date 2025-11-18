class_name Level
extends Node2D


func _ready() -> void:
	self.y_sort_enabled = true
	PlayerManager.set_as_parent( self )
	# PlayerManager.set_player_position(global_position + LevelManager.position_offset)
	LevelManager.level_load_started.connect( _free_level)



func _free_level() -> void:
	PlayerManager.unparent_player( self )
	#LevelManager.level_load_started.connect( _free_level )
	
	queue_free()
	
	pass

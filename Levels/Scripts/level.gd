class_name Level
extends Node2D

# @onready var train: ExpressTrain = $ExpressTrain


func _ready() -> void:
	self.y_sort_enabled = true
	PlayerManager.set_as_parent( self )
	# PlayerManager.set_player_position(global_position + LevelManager.position_offset)
	LevelManager.level_load_started.connect( _free_level)
	
	# train testing
	#var player := PlayerManager.player
	#if player:
		
		#train.global_position.x = player.global_position.x - 900.0
		#train.global_position.y = player.global_position.y - 20
	#train.setup(Vector2.RIGHT)



func _free_level() -> void:
	PlayerManager.unparent_player( self )
	#LevelManager.level_load_started.connect( _free_level )
	
	queue_free()
	
	pass
